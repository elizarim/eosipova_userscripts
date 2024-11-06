import SwiftUI

struct WindowObserver<Content: View>: View {
    var window: WindowBox

    @ViewBuilder var content: Content

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State private var isFullscreen = false

    var body: some View {
        content
            .environment(\.window, window)
            .environment(\.isFullscreen, isFullscreen)
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
                self.isFullscreen = true
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
                self.isFullscreen = false
            }
    }
}
