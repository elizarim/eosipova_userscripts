import AppKit
import SwiftUI
import Combine

/// Provides an auto-updating reference to ``AppWindowController``. The value will update as the key window
/// changes, and does not keep a strong reference to the controller.
///
/// Sample usage:
/// ```swift
/// struct WindowCommands: Commands {
///     @UpdatingWindowController var windowController
///
///     var body: some Commands {
///         Button("Button that needs the window") {
///             print("Window exists")
///         }
///         .disabled(windowController == nil)
///     }
/// }
/// ```
@propertyWrapper
struct UpdatingWindowController: DynamicProperty {
    @StateObject var box = WindowControllerBox()

    var wrappedValue: AppWindowController? {
        box.controller
    }

    class WindowControllerBox: ObservableObject {
        public private(set) weak var controller: AppWindowController?

        private var objectWillChangeCancellable: AnyCancellable?
        private var windowCancellable: AnyCancellable?
        private var activeEditorCancellable: AnyCancellable?

        init() {
            windowCancellable = NSApp.publisher(for: \.keyWindow).sink { [weak self] window in
                self?.setNewController(window?.windowController as? AppWindowController)
            }
        }

        func setNewController(_ controller: AppWindowController?) {
            objectWillChangeCancellable?.cancel()
            objectWillChangeCancellable = nil
            activeEditorCancellable?.cancel()
            activeEditorCancellable = nil

            self.controller = controller

            objectWillChangeCancellable = controller?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            let activeEditor = controller?.workspace?.diagramEditor
            activeEditorCancellable = activeEditor?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            self.objectWillChange.send()
        }
    }
}
