import SwiftUI

@main
struct DiagramEditorApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate

    init() {
        _ = AppDocumentController.shared
    }

    var body: some Scene {
        Group {
            WelcomeWindow()
                .commands {
                    FileCommands()
                }
            AboutWindow()
        }
    }
}
