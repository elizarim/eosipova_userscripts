typealias DiagramInputNode = InputNode<DiagramNode, LeafDiagramNode>
typealias DiagramCircleNode = DiagramInputNode.PackedNode

extension DiagramCircleNode {
    var diagramNode: DiagramNode {
        switch state {
        case let .branch(state): return state.payload
        case let .leaf(state): return state.payload
        }
    }
}

extension LeafDiagramNode: Measurable {}

extension CircleNode {
    var isLeaf: Bool {
        switch state {
        case .branch: return false
        case .leaf: return true
        }
    }

    var children: [CircleNode]? {
        switch state {
        case let .branch(state): return state.children
        case .leaf: return nil
        }
    }
}
