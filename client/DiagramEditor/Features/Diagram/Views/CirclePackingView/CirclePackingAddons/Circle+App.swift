import Foundation

extension Circle {
    var frame: NSRect {
        NSRect(
            origin: NSPoint(
                x: center.x - radius,
                y: center.y - radius
            ),
            size: NSSize(width: 2*radius, height: 2*radius)
        )
    }
}
