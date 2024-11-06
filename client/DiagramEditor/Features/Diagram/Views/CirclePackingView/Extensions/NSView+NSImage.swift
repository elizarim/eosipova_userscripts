import AppKit

extension NSView {
    func renderImage(size: NSSize) -> NSImage {
        let snapshotRect = CGRect(origin: .zero, size: size)
        let bitmapRep = self.bitmapImageRepForCachingDisplay(in: snapshotRect)!
        self.cacheDisplay(in: snapshotRect, to: bitmapRep)
        let renderedImage = NSImage(size: snapshotRect.size)
        renderedImage.addRepresentation(bitmapRep)
        return renderedImage
    }
}

extension NSImage {
    func write(to url: URL) throws {
        guard
            let tiffData = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0])
        else {
            throw CocoaError(.fileWriteUnknown)
        }
        try pngData.write(to: url)
    }
}
