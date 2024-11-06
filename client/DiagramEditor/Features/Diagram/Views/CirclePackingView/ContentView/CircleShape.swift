import Foundation

struct CircleShape: Equatable {
    var frame: NSRect
    var attributes: CircleShapeAttributes

    var dirtyFrame: NSRect {
        (attributes.line?.width).map { frame.insetBy(dx: -$0, dy: -$0) } ?? frame
    }

    func magnified(by magnification: CGFloat) -> Self {
        var result = self
        result.attributes.line?.width /= magnification
        return result
    }
}
