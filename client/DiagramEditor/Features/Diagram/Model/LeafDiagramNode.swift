import Foundation

final class LeafDiagramNode: DiagramNode {
    var size: Double = 8.0

    override init(id: UUID = .init(), name: String, parent: BranchDiagramNode? = nil) {
        super.init(id: id, name: name, parent: parent)
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case size
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        size = try values.decode(Double.self, forKey: .size)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try super.encode(to: encoder)
    }
}
