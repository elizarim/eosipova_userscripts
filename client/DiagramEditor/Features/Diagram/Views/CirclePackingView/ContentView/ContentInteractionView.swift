import AppKit

final class ContentInteractionView: BaseView {
    weak var contentView: ContentView!
    private var delegate: CirclePackingViewDelegate? { contentView.delegate }

    private var mouseDownLocation: Point?
    private var mouseDownPath: CircleNodePath?

    // MARK: - Overrides
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        mouseDownPath = nil
        mouseDownLocation = nil
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        mouseDownPath = findCircle(at: event.locationInWindow)
        mouseDownLocation = extractLocation(from: event.locationInWindow)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        defer {
            mouseDownPath = nil
            mouseDownLocation = nil
        }
        guard
            let delegate,
            let mouseUpPath = findCircle(at: event.locationInWindow),
            mouseUpPath == mouseDownPath
        else {
            return
        }
        delegate.circlePackingViewDidClickedNode(mouseUpPath.lastCircle.diagramNode)
    }

    // MARK: - Private

    private func findCircle(at locationInWindow: CGPoint) -> CircleNodePath? {
        guard let delegate, let rootCircle = contentView.rootCircle else {
            return nil
        }
        let path = CircleNodePath(circles: [rootCircle], viewportOrigin: contentView.margin)
        let context = CircleNodePath.LookupContext(
            coordinate: RelativeCoordinate(
                location: contentView.extractLocation(from: locationInWindow),
                viewportOrigin: .zero
            ),
            delegate: delegate,
            delegateContext: drawingContext(for: path)
        )
        return path.findBranch(for: context)
    }
    
    private func drawingContext(for nodePath: CircleNodePath) -> CircleDrawingContext {
        CircleDrawingContext(
            level: nodePath.circles.count - 1,
            magnification: contentView.magnification
        )
    }
}

// MARK: - Private Extensions

private extension NSView {
    @inline(__always)
    func extractLocation(from location: CGPoint) -> Point {
        Point(convert(location, from: nil))
    }
}

private extension Point {
    init(_ p: NSPoint) {
        self.init(x: p.x, y: p.y)
    }
}
