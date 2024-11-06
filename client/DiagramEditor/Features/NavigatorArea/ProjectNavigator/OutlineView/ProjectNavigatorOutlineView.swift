import SwiftUI
import Combine

/// Wraps an ``OutlineViewController`` inside a `NSViewControllerRepresentable`
struct ProjectNavigatorOutlineView: NSViewControllerRepresentable {
    typealias NSViewControllerType = ProjectNavigatorViewController

    @EnvironmentObject var workspace: WorkspaceDocument

    func makeNSViewController(context: Context) -> ProjectNavigatorViewController {
        let controller = ProjectNavigatorViewController()
        controller.workspace = workspace
        workspace.diagramEditor.addDelegate(context.coordinator)

        context.coordinator.controller = controller

        return controller
    }

    func updateNSViewController(_ nsViewController: ProjectNavigatorViewController, context: Context) {
        /// if the window becomes active from background, it will restore the selection to outline view.
        nsViewController.updateSelection(nodeID: workspace.diagramEditor.selectedNode?.id)
        return
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(workspace)
    }

    class Coordinator: NSObject, DiagramEditorDelegate {
        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
            super.init()
            workspace.diagramEditor.$selectedNode
                .sink(receiveValue: { [weak self] node in
                    guard let node else { return }
                    self?.controller?.reveal(node)
                })
                .store(in: &cancellables)
        }

        private var cancellables: Set<AnyCancellable> = []
        weak var workspace: WorkspaceDocument?
        weak var controller: ProjectNavigatorViewController?

        func diagramEditorUpdated(updates: [DiagramEditorUpdate]) {
            guard let outlineView = controller?.outlineView else { return }
            for update in updates {
                outlineView.reloadItem(update.node, reloadChildren: update.isRecursive)
            }
        }

        deinit {
            workspace?.diagramEditor.removeObserver(self)
        }
    }
}
