import Foundation

public protocol Measurable {
    var size: FloatType { get }
}

public enum InputNode<BranchPayload, LeafPayload: Measurable> {
    case branch(payload: BranchPayload, children: [InputNode])
    case leaf(payload: LeafPayload)
}

extension InputNode {
    /// Counts a number of nodes, including itself.
    public var count: Int {
        switch self {
        case let .branch(_, children): return children.reduce(1) { $0 + $1.count }
        case .leaf: return 1
        }
    }
}

public struct PackingConfig {
    public enum Padding {
        /// A distance between nesting circles does not depend on their size.
        case fixed(value: Distance)
        /// A distance between nesting circles depends on their size.
        case dynamic(factor: FloatType = 1.0)
    }

    public let padding: Padding
    public let emptyRadius: CircleRadius

    public init(padding: Padding, emptyRadius: CircleRadius) {
        self.padding = padding
        self.emptyRadius = emptyRadius
    }
}

extension InputNode {
    public typealias PackedNode = CircleNode<BranchPayload, LeafPayload>

    /// Orders node's content spatially in spiral and then wraps it into the smallest circle.
    public func pack(using config: PackingConfig) -> PackedNode {
        switch self {
        case let .branch(payload, nodes): return packBranch(nodes, with: payload, using: config)
        case let .leaf(payload): return PackedNode(payload: payload, radius: payload.size)
        }
    }
}

extension InputNode: ExpressibleByFloatLiteral where LeafPayload == FloatType {
    public init(floatLiteral value: FloatType) {
        self = .leaf(payload: value)
    }
}

extension InputNode: ExpressibleByArrayLiteral where BranchPayload == Void {
    public init(arrayLiteral elements: InputNode...) {
        self = .branch(payload: (), children: elements)
    }
}

// MARK: - Private

// MARK: - Packing -

private extension InputNode {
    func packBranch(
        _ children: [InputNode],
        with payload: BranchPayload,
        using config: PackingConfig
    ) -> PackedNode {
        var circles = children.map { $0.pack(using: config) }
        return packCircles(&circles, with: payload, using: config)
    }

    private func packCircles(
        _ circles: inout [PackedNode],
        with payload: BranchPayload,
        using config: PackingConfig
    ) -> PackedNode {
        let padding = config.padding.calculate(for: circles)
        circles.orderSpatially(padding: padding)
        return group(&circles, with: payload, using: padding, emptyRadius: config.emptyRadius)
    }
}

// MARK: - Grouping -

private extension InputNode {
    /// Returns the smallest circle that embeds into itself all source circles.
    func group(
        _ nodes: inout [PackedNode],
        with payload: BranchPayload,
        using padding: Distance,
        emptyRadius: Distance
    ) -> PackedNode {
        switch nodes.count {
        case 0:
            return PackedNode(payload: payload, radius: emptyRadius, children: nodes)
        case 1:
            return PackedNode(payload: payload, radius: nodes[0].radius + padding, children: nodes)
        default:
            return groupMultipleNodes(&nodes, with: payload, using: padding)
        }
    }

    private func groupMultipleNodes(
        _ nodes: inout [PackedNode],
        with payload: BranchPayload,
        using padding: Distance
    ) -> PackedNode {
        let firstCircle = nodes.last!
        let (secondCircle, _) = firstCircle.findMostDistantCircle(in: nodes)
        let outerCircle = OuterCircle(for: firstCircle, secondCircle).union(nodes)
        nodes.translate(by: -outerCircle.center)
        return PackedNode(payload: payload, radius: outerCircle.radius + padding, children: nodes)
    }
}

private extension PackingConfig.Padding {
    func calculate(for nodes: [some Circle]) -> Distance {
        switch self {
        case let .fixed(value):
            return value
        case let .dynamic(factor):
            let sumRadii = nodes.reduce(0) { sum, node in sum + node.radius }
            return factor * (0.01*sumRadii + log2(sumRadii))
        }
    }
}

private extension Array where Element: Circle {
    /// Moves circles' center by source delta.
    mutating func translate(by delta: Point) {
        for i in 0..<count {
            self[i].center += delta
        }
    }
}

// MARK: - Ordering -

private extension Array where Element: Circle {
    mutating func orderSpatially(padding: Distance) {
        guard count > 1 else {
            return
        }
        sort { $0.radius < $1.radius }
        self[1].put(nextTo: self[0], padding: padding)
        var pivot = 0, current = 2
        while current < count {
            let head = current - 1
            assert(pivot != head)
            var circle = self[current]
            circle.put(between: self[head], self[pivot], padding: padding)
            if let collision =
                circle.firstCollisionIndex(in: self, between: pivot + 1, head - 1, padding: padding) {
                pivot = collision
                continue
            }
            self[current] = circle
            current += 1
        }
    }
}
