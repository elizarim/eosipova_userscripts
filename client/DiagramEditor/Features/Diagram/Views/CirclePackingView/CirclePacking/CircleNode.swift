import Foundation

public struct CircleNode<BranchPayload, LeafPayload> {
    public enum State {
        public struct Leaf {
            public var payload: LeafPayload
        }

        public struct Branch {
            public var payload: BranchPayload
            public var children: [CircleNode]
        }

        case branch(_ state: Branch)
        case leaf(_ state: Leaf)
    }

    public var state: State
    var geometry: FlatCircle
}

extension CircleNode: Circle {
    public var radius: CircleRadius {
        get { geometry.radius }
        set { geometry.radius = newValue }
    }

    public var center: Point {
        get { geometry.center }
        set { geometry.center = newValue }
    }
}

// MARK: - Internal -

extension CircleNode {
    init(payload: LeafPayload, radius: CircleRadius, center: Point = .zero) {
        state = .leaf(.init(payload: payload))
        geometry = FlatCircle(radius: radius, center: center)
    }

    init(
        payload: BranchPayload,
        radius: CircleRadius,
        center: Point = .zero,
        children: [CircleNode] = []
    ) {
        state = .branch(.init(payload: payload, children: children))
        geometry = FlatCircle(radius: radius, center: center)
    }
}
