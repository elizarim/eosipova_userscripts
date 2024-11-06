import AppKit

extension CGContext {
    func drawEllipse(in frame: NSRect, with attributes: CircleShapeAttributes) {
        if let color = attributes.fillColor {
            setFillColor(color.cgColor)
            fillEllipse(in: frame)
        }
        if let line = attributes.line {
            setStrokeColor(line.color.cgColor)
            setLineWidth(line.width)
            strokeEllipse(in: frame)
        }
    }

    func drawText(_ text: String, in frame: NSRect, with attributes: CircleShapeAttributes) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 12)
        ]
        let title = NSAttributedString(string: text, attributes: titleAttributes)
        let titleLine = CTLineCreateWithAttributedString(title)
        var ascent: CGFloat = 0.0
        var descent: CGFloat = 0.0
        var leading: CGFloat = 0.0
        let lineWidth = CGFloat(floor(CTLineGetTypographicBounds(titleLine, &ascent, &descent, &leading) + 0.5))
        let lineHeight = floor(ascent + leading)
        textPosition = NSPoint(
            x: frame.midX - lineWidth / 2,
            y: frame.midY - lineHeight / 2
        )
        CTLineDraw(titleLine, self)
    }
}
