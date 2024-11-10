import SwiftUI

struct ProjectNavigatorToolbarBottom: View {
    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject var workspace: WorkspaceDocument

    var body: some View {
        HStack(spacing: 5) {
            addNewNodeButton
            Spacer()
        }
        .padding(.horizontal, 5)
        .frame(height: 28, alignment: .leading)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    /// Retrieves the active branch from the underlying editor instance, if theres no
    /// one, fallbacks to the workspace's root node
    private var activeBranch: DiagramNode? {
        if let selectedNode = workspace.diagramEditor.selectedNode {
            if selectedNode.isBranch {
                return selectedNode
            } else {
                return selectedNode.parent
            }
        }
        return workspace.diagramEditor.rootNode
    }

    private var addNewNodeButton: some View {
        Menu {
            Button("Add Leaf") {
                guard let parentNode = activeBranch as? BranchDiagramNode else {
                    let alert = NSAlert(error: CocoaError(.fileLocking))
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                    return
                }
                workspace.diagramEditor.addNode(LeafDiagramNode(name: "Leaf"), to: parentNode)
            }
            Button("Add Branch") {
                guard let parentNode = activeBranch as? BranchDiagramNode else {
                    let alert = NSAlert(error: CocoaError(.fileLocking))
                    alert.addButton(withTitle: "Dismiss")
                    alert.runModal()
                    return
                }
                workspace.diagramEditor.addNode(BranchDiagramNode(name: "Branch"), to: parentNode)
            }
        } label: {}
        .background {
            Image(systemName: "plus")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
