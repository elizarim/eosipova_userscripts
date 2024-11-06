import Foundation

public struct Point: Equatable {
    public var x: Distance
    public var y: Distance

    public init(x: Distance, y: Distance) {
        self.x = x
        self.y = y
    }
}

extension Point {
    /// The point with location (0,0).
    public static var zero: Point { Point(x: .zero, y: .zero) }
}

extension Point {
    public static prefix func - (p: Point) -> Point { Point(x: -p.x, y: -p.y) }

    public static func - (a: Point, b: Point) -> Point { Point(x: a.x - b.x, y: a.y - b.y) }
    public static func + (a: Point, b: Point) -> Point { Point(x: a.x + b.x, y: a.y + b.y) }

    public static func += (lhs: inout Point, rhs: Point) { lhs = lhs + rhs }
    public static func -= (lhs: inout Point, rhs: Point) { lhs = lhs - rhs }

    public static func *= (p: inout Point, m: Distance) { p = Point(x: p.x*m, y: p.y*m) }
    public static func /= (p: inout Point, d: Distance) { p = Point(x: p.x/d, y: p.y/d) }
}

// MARK: - Internal -

extension Point {
    /// Measures euclidean distance from that point to the source one.
    func distance(to point: Point) -> Distance { hypot(x - point.x, y - point.y) }
}
