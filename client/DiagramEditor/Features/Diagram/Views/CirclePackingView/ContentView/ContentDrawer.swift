import AppKit

struct ContentDrawer {
    struct Context {
        var dirtyRect: NSRect
        var delegate: CirclePackingViewDelegate
        var delegateContext: CircleDrawingContext
        var maxDrawingLevel: Int?
    }
    
    struct Stats {
        var drawCount: Int
    }
    
    func draw(_ circle: DiagramCircleNode, context: Context, stats: inout Stats) {
        guard shouldDraw(circle, in: context) else {
            return
        }
        let attributes = context.delegate.shapeAttributes(for: circle, with: context.delegateContext)
        drawCircle(in: circle.frame, with: attributes, stats: &stats)
        drawChildren(of: circle, with: context, stats: &stats)
        if !circle.diagramNode.isNameHidden {
            NSGraphicsContext.current!.cgContext.drawText(circle.diagramNode.name, in: circle.frame, with: attributes)
        }
    }
    
    func drawCircleShape(_ shape: CircleShape, context: Context, stats: inout Stats) {
        let drawingShape = shape.magnified(by: context.delegateContext.magnification)
        guard NSIntersectsRect(drawingShape.dirtyFrame, context.dirtyRect) else {
            return
        }
        drawCircle(in: drawingShape.frame, with: drawingShape.attributes, stats: &stats)
    }
    
    private func drawCircle(in frame: NSRect, with attributes: CircleShapeAttributes, stats: inout Stats) {
        NSGraphicsContext.current!.cgContext.drawEllipse(in: frame, with: attributes)
        stats.drawCount += 1
    }

    private func drawChildren(of circle: DiagramCircleNode, with context: Context, stats: inout Stats) {
        guard let children = circle.children else {
            return
        }
        if !context.delegate.shouldDrawChildren(of: circle, context: context.delegateContext) {
            return
        }
        NSGraphicsContext.with(translation: circle.center) { transform in
            var childrenContext = context.transformed(by: transform.inverted())
            childrenContext.delegateContext.level += 1
            children.forEach { self.draw($0, context: childrenContext, stats: &stats) }
        }
    }
    
    private func shouldDraw(_ circle: Circle, in context: Context) -> Bool {
        if let maxDrawingLevel = context.maxDrawingLevel, context.delegateContext.level > maxDrawingLevel {
            return false
        }
        return NSIntersectsRect(circle.frame, context.dirtyRect)
    }
    
    private func childrenContext(from context: Context, applying transform: CGAffineTransform) -> Context {
        Context(
            dirtyRect: context.dirtyRect.applying(transform),
            delegate: context.delegate,
            delegateContext: CircleDrawingContext(
                level: context.delegateContext.level + 1,
                magnification: context.delegateContext.magnification
            ),
            maxDrawingLevel: context.maxDrawingLevel
        )
    }
}

extension ContentDrawer.Context {
    func transformed(by transform: CGAffineTransform) -> Self {
        .init(
            dirtyRect: dirtyRect.applying(transform),
            delegate: delegate,
            delegateContext: delegateContext,
            maxDrawingLevel: maxDrawingLevel
        )
    }
}

private extension ContentDrawer {
    enum Constants {
        static var branchNodeColorAlpha: CGFloat { 0.20 }
    }
}
