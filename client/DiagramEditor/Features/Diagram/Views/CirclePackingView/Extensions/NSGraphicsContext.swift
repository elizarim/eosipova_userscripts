import AppKit

extension NSGraphicsContext {
    static func with(translation point: Point, _ draw: (CGAffineTransform) -> Void) {
        let context = current!.cgContext
        let transform = CGAffineTransform(translationX: point.x, y: point.y)
        context.concatenate(transform)
        draw(transform)
        context.concatenate(transform.inverted())
    }
}
