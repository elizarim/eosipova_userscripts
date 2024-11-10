import Foundation

public struct Rect: Equatable {
    public var origin: Point
    public var size: Size

    var minX: Distance { origin.x }
    var maxX: Distance { origin.x + size.width }
    var minY: Distance { origin.y }
    var maxY: Distance { origin.y + size.height }

    /// Point where diameters intersect each other.
    var center: Point {
        Point(
            x: origin.x + size.width/2.0,
            y: origin.y + size.height/2.0
        )
    }

    /// The rectangle whose origin and size are both zero.
    public static var zero: Rect {
        Rect(origin: .zero, size: .zero)
    }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    /// Returns the smallest rectangle that contains all source points.
    static func union(_ points: [Point]) -> Rect {
        guard !points.isEmpty else {
            return .zero
        }
        var minX = points.first!.x
        var maxX = minX
        var minY = points.first!.y
        var maxY = minY
        for point in points.dropFirst() {
            if minX > point.x { minX = point.x }
            if maxX < point.x { maxX = point.x }
            if minY > point.y { minY = point.y }
            if maxY < point.y { maxY = point.y }
        }
        return Rect(
            origin: Point(x: minX, y: minY),
            size: Size(width: maxX - minX, height: maxY - minY)
        )
    }

    /// Determines if there is a shared area between that and the specified rectangle.
    public func isJoined(with rect: Rect) -> Bool {
        // Calculating the bottom-left and top-right points
        // of a shared area and checking the results.
        let minX = max(minX, rect.minX)
        let minY = max(minY, rect.minY)
        let maxX = min(maxX, rect.maxX)
        let maxY = min(maxY, rect.maxY)
        return minX <= maxX && minY <= maxY
    }
}

public struct Size: Equatable {
    public var width: Distance
    public var height: Distance

    public static var zero: Size { Size(width: .zero, height: .zero) }

    public init(width: Distance, height: Distance) {
        precondition(width >= .zero && height >= .zero)
        self.width = width
        self.height = height
    }
}
