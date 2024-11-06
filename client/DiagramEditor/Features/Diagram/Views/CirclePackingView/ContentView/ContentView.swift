import AppKit

final class ContentView: BaseView {
    var rootCircle: DiagramCircleNode? {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    var backgroundColor: NSColor?
    override var isOpaque: Bool { true }
    
    var margin: Point { .init(x: marginSize, y: marginSize) }
    var marginSize: Distance = .zero {
        didSet {
            frame = CGRect(origin: .zero, size: intrinsicContentSize)
        }
    }
    
    override var intrinsicContentSize: NSSize {
        let sideSize = 2 * ((rootCircle?.radius ?? .zero) + marginSize)
        return CGSize(width: sideSize, height: sideSize)
    }
    
    var delegate: CirclePackingViewDelegate?
    
    var magnification: CGFloat = 1.0
    var maxDrawingLevel: Int? {
        didSet {
            if maxDrawingLevel != oldValue {
                setNeedsDisplay()
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let delegate else {
            return
        }
        measureDraw(silent: true) {
            let drawer = ContentDrawer()
            let context = ContentDrawer.Context(
                dirtyRect: dirtyRect,
                delegate: delegate,
                delegateContext: CircleDrawingContext(level: 0, magnification: magnification),
                maxDrawingLevel: maxDrawingLevel
            )
            var stats = ContentDrawer.Stats(drawCount: 0)
            let cgContent = NSGraphicsContext.current!.cgContext
            if let backgroundColor {
                cgContent.setFillColor(backgroundColor.cgColor)
                cgContent.fill([dirtyRect])
            }
            NSGraphicsContext.with(translation: margin) { transform in
                if let rootCircle {
                    drawer.draw(rootCircle, context: context.transformed(by: transform.inverted()), stats: &stats)
                }
            }
            return stats
        }
    }
    
    private func measureDraw(silent: Bool, drawBlock: () -> ContentDrawer.Stats) {
        let drawingStartTime = CFAbsoluteTimeGetCurrent()
        let drawingStats = drawBlock()
        let drawingFinishTime = CFAbsoluteTimeGetCurrent()
        let drawingDuration = drawingFinishTime - drawingStartTime
        let drawingDurationString = String(format: "%.6f", drawingDuration)
        let nodeDrawingDurationString = String(format: "%.9f", drawingDuration/CFTimeInterval(drawingStats.drawCount))
        if !silent {
            NSLog("draw: count=\(drawingStats.drawCount), total=\(drawingDurationString)s, avg=\(nodeDrawingDurationString)s")
        }
    }
}
