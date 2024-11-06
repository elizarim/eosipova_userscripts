import Foundation

struct CloudDiagram: Codable, Identifiable {
    var id: UUID
    var message: String
    var createdAt: Date

    static func == (lhs: CloudDiagram, rhs: CloudDiagram) -> Bool {
        lhs.id == rhs.id
    }
}
