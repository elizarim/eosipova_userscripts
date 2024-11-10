import Foundation

extension ProjectNavigatorViewController: OutlineTableViewCellDelegate {
    func renameNode(_ node: DiagramNode, newName: String) {
        workspace?.diagramEditor.renameNode(node, newName: newName)
        workspace?.diagramEditor.selectNode(node)
    }
}
