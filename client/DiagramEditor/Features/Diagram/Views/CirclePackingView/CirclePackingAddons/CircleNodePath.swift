import Foundation

typealias CircleNodePath = CircleNodeSubPath<Array<DiagramCircleNode>>

struct CircleNodeSubPath<Circles: RandomAccessCollection> where Circles.Element == DiagramCircleNode {
    typealias Circle = Circles.Element

    struct LookupContext {
        var coordinate: RelativeCoordinate
        var delegate: CirclePackingViewDelegate
        var delegateContext: CircleDrawingContext
    }

    let circles: Circles
    var lastCircle: Circle { circles.last! }
    var lastCircleFrame: CGRect { lastCircle.frame.offsetBy(dx: viewportOrigin.x, dy: viewportOrigin.y) }
    let viewportOrigin: Point

    init(circles: Circles, viewportOrigin: Point) {
        precondition(!circles.isEmpty)
        self.circles = circles
        self.viewportOrigin = viewportOrigin
    }
}

extension CircleNodePath {
    func findBranch(for context: LookupContext) -> Self? {
        if contains(context.coordinate) {
            return extended(for: context)
        } else if let (path, pathContext) = shortened(for: context) {
            return path.extended(for: pathContext)
        } else {
            return nil
        }
    }
}

extension CircleNodePath: Equatable {
    static func == (lhs: CircleNodePath, rhs: CircleNodePath) -> Bool {
        lhs.lastCircleFrame == rhs.lastCircleFrame
    }
}

private extension CircleNodePath {
    func shortened(for context: LookupContext) -> (Self, LookupContext)? {
        var pathContext = context
        var path = dropLast()
        if path != nil {
            pathContext = pathContext.decrementLevel()
        }
        while let subpath = path {
            if subpath.contains(pathContext.coordinate) {
                return (.init(circles: Array(subpath.circles), viewportOrigin: subpath.viewportOrigin), pathContext)
            }
            path = subpath.dropLast()
            if path != nil {
                pathContext = pathContext.decrementLevel()
            }
        }
        return nil
    }

    func extended(for context: LookupContext) -> Self {
        var path = self
        var pathContext = context
        while let subtree = path.findChildren(for: pathContext) {
            path = path.joined(with: subtree, contained: pathContext.coordinate)
            pathContext = pathContext.incrementLevel()
        }
        return path
    }
}

private extension CircleNodeSubPath {
    func contains(_ c: RelativeCoordinate) -> Bool {
        lastCircle.contains(localCoordinate(from: c).location)
    }

    func joined(with circle: Circle, contained coordinate: RelativeCoordinate) -> CircleNodePath {
        .init(
            circles: circles + [circle],
            viewportOrigin: childrenCoordinate(from: coordinate).viewportOrigin
        )
    }

    func findChildren(for context: LookupContext) -> Circle? {
        guard
            !lastCircle.isLeaf,
            context.delegate.shouldDrawChildren(of: lastCircle, context: context.delegateContext)
        else {
            return nil
        }
        let childrenCoordinate = childrenCoordinate(from: context.coordinate)
        return lastCircle.children?.first { $0.contains(childrenCoordinate.location) }
    }

    func dropLast() -> CircleNodeSubPath<Circles.SubSequence>? {
        guard circles.count > 1 else {
            return nil
        }
        let lastCircles = circles.dropLast()
        return .init(circles: lastCircles, viewportOrigin: viewportOrigin - lastCircles.last!.center)
    }

    /// Converts a coordinate from the coordinate system of a given viewport to that used to position children of the last circle in the path.
    @inline(__always)
    func childrenCoordinate(from coordinate: RelativeCoordinate) -> RelativeCoordinate {
        localCoordinate(from: coordinate).offsetViewport(by: lastCircle.center)
    }

    /// Converts a coordinate from the coordinate system of a given viewport to that used to position the last circle in the path.
    @inline(__always)
    func localCoordinate(from coordinate: RelativeCoordinate) -> RelativeCoordinate {
        coordinate.offsetViewport(by: viewportOrigin - coordinate.viewportOrigin)
    }
}

private extension CircleNodeSubPath.LookupContext {
    func incrementLevel() -> Self {
        update(level: delegateContext.level + 1)
    }

    func decrementLevel() -> Self {
        update(level: delegateContext.level - 1)
    }

    func update(level: Int) -> Self {
        Self(
            coordinate: coordinate,
            delegate: delegate,
            delegateContext: CircleDrawingContext(level: level, magnification: delegateContext.magnification)
        )
    }
}
