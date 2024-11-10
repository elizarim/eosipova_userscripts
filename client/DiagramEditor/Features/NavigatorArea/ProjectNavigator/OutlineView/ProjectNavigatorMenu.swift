import SwiftUI
import UniformTypeIdentifiers

/// A subclass of `NSMenu` implementing the contextual menu for the project navigator
final class ProjectNavigatorMenu: NSMenu {
    var node: DiagramNode?
    var workspace: WorkspaceDocument?
    var outlineView: NSOutlineView

    init(sender: NSOutlineView) {
        outlineView = sender
        super.init(title: "Options")
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Creates a `NSMenuItem` depending on the given arguments
    /// - Parameters:
    ///   - title: The title of the menu item
    ///   - action: A `Selector` or `nil` of the action to perform.
    ///   - key: A `keyEquivalent` of the menu item. Defaults to an empty `String`
    /// - Returns: A `NSMenuItem` which has the target `self`
    private func menuItem(_ title: String, action: Selector?, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    private func setupMenu() {
        guard let node else { return }
        let newLeaf = menuItem("New Leaf", action: #selector(newLeaf))
        let newBranch = menuItem("New Branch", action: #selector(newBranch))
        let rename = menuItem("Rename", action: #selector(renameFile))
        let delete = menuItem("Delete", action: #selector(delete))
        if node.isBranch {
            items = [
                newLeaf,
                newBranch,
                NSMenuItem.separator(),
                rename,
                delete,
            ]
        } else {
            items = [
                rename,
                delete,
            ]
        }
    }

    override func update() {
        removeAllItems()
        setupMenu()
    }

    @objc
    private func newLeaf() {
        guard let node = self.node as? BranchDiagramNode else { return }
        workspace?.diagramEditor.addNode(LeafDiagramNode(name: "Leaf"), to: node)
        outlineView.expandItem(node.isBranch ? node : node.parent)
    }

    @objc
    private func newBranch() {
        guard let node = self.node as? BranchDiagramNode else { return }
        workspace?.diagramEditor.addNode(BranchDiagramNode(name: "Branch"), to: node)
        outlineView.expandItem(node)
        outlineView.expandItem(node.isBranch ? node : node.parent)
    }

    @objc
    private func renameFile() {
        let row = outlineView.row(forItem: node)
        let cell = outlineView.view(
            atColumn: 0,
            row: row,
            makeIfNecessary: false
        ) as? ProjectNavigatorTableViewCell
        guard let cell else { return }
        outlineView.window?.makeFirstResponder(cell.textField)
    }

    @objc
    private func delete() {
        guard let node else { return }
        workspace?.diagramEditor.deleteNode(node)
    }
}
