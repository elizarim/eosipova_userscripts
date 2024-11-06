import Combine
import SwiftUI

struct DiagramView: NSViewRepresentable {
    @EnvironmentObject var workspace: WorkspaceDocument

    func makeNSView(context: Context) -> CirclePackingView {
        let view = CirclePackingView()
        if let rootCircle = context.coordinator.rootNode {
            view.rootCircle = rootCircle
        }
        view.magnification = 1
        view.delegate = context.coordinator.editor
        context.coordinator.circlesView = view
        return view
    }

    func makeCoordinator() -> DiagramEditorCoordinator {
        let coordinator = DiagramEditorCoordinator(workspace)
        workspace.diagramEditor.view = coordinator
        return coordinator
    }

    func updateNSView(_ nsView: CirclePackingView, context: Context) {
    }
}

final class DiagramEditorCoordinator: NSObject, DiagramEditorView {
    let rootNode: DiagramCircleNode?
    let editor: DiagramEditor
    weak var circlesView: CirclePackingView?
    private var cancellables: Set<AnyCancellable> = []

    init(_ workspace: WorkspaceDocument) {
        self.editor = workspace.diagramEditor
        self.rootNode = workspace.diagramEditor.rootCircleNode
    }

    // MARK: DiagramEditorView

    func renderImage() -> NSImage? {
        guard let circlesView else { return nil }
        return circlesView.renderImage(size: circlesView.intrinsicContentSize)
    }
}
