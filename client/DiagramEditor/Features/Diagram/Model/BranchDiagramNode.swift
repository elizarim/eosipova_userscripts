import Foundation

final class BranchDiagramNode: DiagramNode {
    private(set) var children: [DiagramNode]?

    override init(id: UUID = .init(), name: String, parent: BranchDiagramNode? = nil) {
        super.init(id: id, name: name, parent: parent)
    }

    override func findNode(by nodeID: ID) -> DiagramNode? {
        if let result = super.findNode(by: nodeID) {
            return result
        }
        guard let children = children else { return nil }
        for child in children {
            if let result = child.findNode(by: nodeID) {
                return result
            }
        }
        return nil
    }

    func add(child: DiagramNode) {
        precondition(child.parent == nil)
        if children == nil {
            children = [child]
        } else {
            children?.append(child)
        }
        child.parent = self
    }

    func remove(child: DiagramNode) {
        precondition(child.parent == self)
        children?.removeAll { $0 == child }
        child.parent = nil
    }

    // MARK: Codable

    enum CodingKeys: String, CodingKey {
        case children
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var children = try container.nestedUnkeyedContainer(forKey: .children)
        if let count = children.count, count > 0 {
            while !children.isAtEnd {
                if let child = try? children.decode(BranchDiagramNode.self) {
                    add(child: child)
                } else if let child = try? children.decode(LeafDiagramNode.self) {
                    add(child: child)
                }
            }
        }
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(children, forKey: .children)
        try super.encode(to: encoder)
    }
}
