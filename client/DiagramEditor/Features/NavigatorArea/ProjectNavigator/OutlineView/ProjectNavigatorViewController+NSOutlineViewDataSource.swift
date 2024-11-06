import AppKit

extension ProjectNavigatorViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
        case let branch as BranchDiagramNode:
            return branch.children?.count ?? 0
        case is LeafDiagramNode:
            return 0
        default:
            return content.count
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let branch = item as? BranchDiagramNode, let children = branch.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is BranchDiagramNode
    }

    /// Write dragged file(s) to pasteboard
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        guard let node = item as? DiagramNode else { return nil }
        return node.id.uuidString as NSString
    }
}
