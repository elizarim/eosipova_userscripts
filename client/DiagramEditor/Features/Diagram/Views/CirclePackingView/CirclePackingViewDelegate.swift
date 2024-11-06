import AppKit

struct CircleDrawingContext {
    var level: Int
    var magnification: CGFloat

    init(level: Int, magnification: CGFloat) {
        precondition(level >= 0)
        precondition(magnification >= 0)
        self.level = level
        self.magnification = magnification
    }
}

protocol CircleDrawing {
    func draw(_ circle: DiagramCircleNode, in frame: NSRect, with: CircleDrawingContext)
}

struct CircleShapeAttributes: Equatable {
    struct Line: Equatable {
        var color: NSColor
        var width: CGFloat = 1.0
    }
    var line: Line?
    var fillColor: NSColor?
}

protocol CirclePackingViewDelegate {
    func shouldDrawChildren(of circle: DiagramCircleNode, context: CircleDrawingContext) -> Bool
    func shapeAttributes(for circle: DiagramCircleNode, with context: CircleDrawingContext) -> CircleShapeAttributes

    func circlePackingViewDidClickedNode(_ clickedNode: DiagramNode)
}
