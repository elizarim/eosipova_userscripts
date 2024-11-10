import SwiftUI

struct FileCommands: Commands {
    @Environment(\.openWindow)
    private var openWindow

    @UpdatingWindowController var windowController

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Group {
                Button("New") {
                    AppDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n")

                Button("Open...") {
                    AppDocumentController.shared.openDocument(nil)
                }
                .keyboardShortcut("o")
            }
        }

        CommandGroup(replacing: .saveItem) {
            Button("Close Window") {
                NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.shift, .command])

            Button("Close Workspace") {
                NSApp.sendAction(#selector(NSWindow.performClose(_:)), to: NSApp.keyWindow, from: nil)
            }
            .keyboardShortcut("w", modifiers: [.control, .option, .command])
            .disabled(!(NSApplication.shared.keyWindow?.windowController is AppWindowController))

            Divider()

            Button("Save") {
                NSApp.sendAction(#selector(AppWindowController.saveDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("s")

            Divider()

            Button("Export Image...") {
                NSApp.sendAction(#selector(AppWindowController.exportDocument(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("e")
        }
    }
}
