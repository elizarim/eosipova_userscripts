import SwiftUI

public struct AboutView: View {
    @Environment(\.dismiss)
    private var dismiss

    public var body: some View {
        ZStack(alignment: .top) {
            AboutDefaultView()
        }
        .ignoresSafeArea()
        .frame(width: 280, height: 400 - 28)
        .fixedSize()
        .background(EffectView(.popover, blendingMode: .behindWindow).ignoresSafeArea())
        .background {
            Button("") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .hidden()
        }
        .task {
            if let window = NSApp.findWindow(.about) {
                window.styleMask = [.closable, .fullSizeContentView, .titled, .nonactivatingPanel]
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.backgroundColor = .gray.withAlphaComponent(0.15)
                window.isMovableByWindowBackground = true
            }
        }
    }
}
