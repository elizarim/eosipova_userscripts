import SwiftUI

struct WorkspaceView: View {
    @Environment(\.window.value)
    private var window: NSWindow?

    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var diagramEditor: DiagramEditor

    var body: some View {
        DiagramAreaView(diagramEditor: diagramEditor)
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { output in
                if let window = output.object as? NSWindow, self.window == window {
                    workspace.addToPersistentState(
                        key: .windowSize,
                        value: NSStringFromRect(window.frame)
                    )
                }
            }
    }
}
