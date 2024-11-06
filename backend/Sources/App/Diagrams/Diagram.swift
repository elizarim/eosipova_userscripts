import Fluent
import Vapor

final class Diagram: Model, Content, @unchecked Sendable {
    static let schema = "diagrams"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "author_id")
    var author: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Field(key: "content_id")
    var contentID: UUID

    @Field(key: "content")
    var content: String

    @Field(key: "message")
    var message: String

    init() {}

    init(contentID: UUID, content: String, message: String) {
        self.contentID = contentID
        self.content = content
        self.message = message
    }
}

extension Diagram {
    struct CreateMigration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("diagrams")
                .id()
                .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
                .field("created_at", .date, .required)
                .field("content_id", .uuid, .required)
                .field("content", .string, .required)
                .field("message", .string, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("diagrams").delete()
        }
    }
}
