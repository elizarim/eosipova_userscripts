import Foundation

@MainActor
final class CloudClient: ObservableObject {
    struct APIError: Error, Decodable {
        var reason: String
    }

    @Published private(set) var account: CloudAccount?
    @Published private(set) var history: [CloudDiagram]?

    private let keychain: AppKeychain

    init(keychain: AppKeychain) {
        self.keychain = keychain
        self.account = CloudAccount.load()
    }

    func signUp(_ serverURL: URL, _ name: String, _ password: String, _ passwordConfirmation: String) async throws {
        let body = """
        {
            "name": "\(name)",
            "password": "\(password)",
            "confirmPassword": "\(passwordConfirmation)"
        }
        """
        var request = URLRequest(url: serverURL.appendingPathComponent("signup"))
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data, response)
    }

    func signIn(_ serverURL: URL, _ name: String, _ password: String) async throws {
        let base64Credentials = Data("\(name):\(password)".utf8).base64EncodedString()
        var request = URLRequest(url: serverURL.appendingPathComponent("signin"))
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data, response)
        let responsePayload = try JSONDecoder().decode(SignInResponse.self, from: data)

        let account = CloudAccount(serverURL: serverURL, name: name)
        try account.save()
        account.saveToken(responsePayload.token, to: keychain)
        self.account = account
    }

    func signOut() {
        guard let account else { return }
        account.eraseEverywhere(including: keychain)
        self.account = nil
    }

    func updateDiagramHistory(contentID: UUID) async throws {
        var request = try authorizedURLRequest(
            queryItems: [URLQueryItem(name: "contentID", value: contentID.uuidString)],
            pathComponents: "diagrams"
        )
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data, response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.history = try decoder.decode([CloudDiagram].self, from: data)
    }

    func fetchDiagram(diagramID: UUID) async throws -> DiagramNode {
        var request = try authorizedURLRequest(pathComponents: "diagrams", diagramID.uuidString)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data, response)
        let decodedResponse = try JSONDecoder().decode(DiagramResponse.self, from: data)
        guard let diagramData = Data(base64Encoded: decodedResponse.content) else {
            throw APIError(reason: "Diagram data is malformed")
        }
        let node = try JSONDecoder().decode(BranchDiagramNode.self, from: diagramData)
        return node
    }

    func commitDiagram(_ diagram: DiagramNode, message: String) async throws {
        let content = try JSONEncoder().encode(diagram)
        let base64Content = content.base64EncodedString()
        var request = try authorizedURLRequest(pathComponents: "diagrams")
        request.httpMethod = "POST"
        let body = """
        {
            "content": "\(base64Content)",
            "contentID": "\(diagram.id.uuidString)",
            "message": "\(message)"
        }
        """
        request.httpBody = body.data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data, response)
    }

    // MARK: Private

    private func authorizedURLRequest(
        queryItems: [URLQueryItem] = [],
        pathComponents: String...
    ) throws -> URLRequest {
        guard
            var serverURL = account?.serverURL,
            let bearerToken = account?.loadToken(from: keychain)
        else {
            throw APIError(reason: "Unauthorized")
        }
        for pathComponent in pathComponents {
            serverURL.append(component: pathComponent)
        }
        serverURL.append(queryItems: queryItems)
        var request = URLRequest(url: serverURL)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validate(_ data: Data, _ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(reason: "Unexpected response")
        }
        if httpResponse.statusCode == 401 {
            signOut()
        }
        if httpResponse.statusCode != 200 {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
        }
    }
}

private struct SignInResponse: Decodable {
    var token: String
}

private struct DiagramResponse: Decodable {
    var content: String
}
