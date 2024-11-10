import Fluent
import Vapor

struct DiagramsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let diagrams = routes
            .grouped(UserToken.authenticator())
            .grouped("diagrams")
        diagrams.get(use: index)
        diagrams.post(use: create)
        diagrams.group(":diagramID") { diagram in
            diagram.get(use: read)
            diagram.delete(use: delete)
        }
    }

    @Sendable
    func index(request: Request) async throws -> [DiagramDTO] {
        let user = try request.auth.require(User.self)
        let diagrams: [Diagram]
        if let query = try? request.query.decode(Index.RequestDTO.self) {
            diagrams = try await user.$diagrams
                .query(on: request.db)
                .filter(\.$contentID == query.contentID)
                .sort(\.$createdAt, .descending)
                .all()
        } else {
            diagrams = try await user.$diagrams
                .query(on: request.db)
                .sort(\.$createdAt, .descending)
                .all()
        }
        return try diagrams.map { diagram in
            try DiagramDTO(
                id: diagram.requireID(),
                authorID: user.requireID(),
                createdAt: diagram.createdAt,
                contentID: diagram.contentID,
                message: diagram.message
            )
        }
    }

    @Sendable
    func create(request: Request) async throws -> DiagramDTO {
        let user = try request.auth.require(User.self)
        let dto = try request.content.decode(Create.RequestDTO.self)
        let diagram = Diagram(contentID: dto.contentID, content: dto.content, message: dto.message)
        try await user.$diagrams.create(diagram, on: request.db)
        return try DiagramDTO(
            id: diagram.requireID(),
            authorID: user.requireID(),
            createdAt: diagram.createdAt,
            contentID: diagram.contentID,
            message: diagram.message
        )
    }

    @Sendable
    func read(request: Request) async throws -> Read.ResponseDTO {
        let user = try request.auth.require(User.self)
        guard let diagram = try await Diagram.find(request.parameters.get("diagramID"), on: request.db) else {
            throw Abort(.notFound)
        }
        let author = try await diagram.$author.get(on: request.db)
        guard author.id == user.id else {
            throw Abort(.notFound)
        }
        return Read.ResponseDTO(content: diagram.content)
    }

    @Sendable
    func delete(request: Request) async throws -> HTTPStatus {
        let user = try request.auth.require(User.self)
        guard let diagram = try await Diagram.find(request.parameters.get("diagramID"), on: request.db) else {
            throw Abort(.notFound)
        }
        let author = try await diagram.$author.get(on: request.db)
        guard author.id == user.id else {
            throw Abort(.notFound)
        }
        try await diagram.delete(on: request.db)
        return .noContent
    }
}

extension DiagramsController {
    struct DiagramDTO: Content {
        var id: UUID
        var authorID: User.IDValue
        var createdAt: Date
        var contentID: UUID
        var message: String

        init(id: Diagram.IDValue, authorID: User.IDValue, createdAt: Date?, contentID: UUID, message: String) throws {
            guard let createdAt else {
                throw Abort(.internalServerError)
            }
            self.id = id
            self.authorID = authorID
            self.createdAt = createdAt
            self.contentID = contentID
            self.message = message
        }
    }

    enum Index {
        struct RequestDTO: Content {
            var contentID: UUID
        }
    }

    enum Create {
        struct RequestDTO: Content {
            var contentID: UUID
            var content: String
            var message: String
        }
    }

    enum Read {
        struct ResponseDTO: Content {
            var content: String
        }
    }
}
