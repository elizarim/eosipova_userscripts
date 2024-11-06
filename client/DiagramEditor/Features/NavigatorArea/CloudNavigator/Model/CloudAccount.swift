import Foundation

struct CloudAccount: Codable {
    var serverURL: URL
    var name: String
}

extension CloudAccount {
    private static var accountKey: String { "account" }
    private var tokenKey: String { "cloud_token_\(name)" }

    static func load() -> Self? {
        guard
            let data = UserDefaults.standard.object(forKey: Self.accountKey) as? Data,
            let account = try? JSONDecoder().decode(CloudAccount.self, from: data)
        else {
            return nil
        }
        return account
    }

    func loadToken(from keychain: AppKeychain) -> String? {
        keychain.get(tokenKey)
    }

    func save() throws {
        let data = try JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: Self.accountKey)
    }

    func saveToken(_ token: String, to keychain: AppKeychain) {
        keychain.set(token, forKey: tokenKey)
    }

    func eraseEverywhere(including keychain: AppKeychain) {
        UserDefaults.standard.removeObject(forKey: Self.accountKey)
        keychain.delete(tokenKey)
    }
}
