import AppKit

extension ProjectNavigatorViewController: NSOutlineViewDelegate {
    func outlineView(
        _ outlineView: NSOutlineView,
        shouldShowCellExpansionFor tableColumn: NSTableColumn?,
        item: Any
    ) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let tableColumn else {
            return nil
        }
        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)
        return ProjectNavigatorTableViewCell(frame: frameRect, node: item as? DiagramNode, delegate: self)
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        let selectedIndex = outlineView.selectedRow
        guard let node = outlineView.item(atRow: selectedIndex) as? DiagramNode else {
            return
        }
        if shouldSendSelectionUpdate {
            DispatchQueue.main.async { [weak self] in
                self?.shouldSendSelectionUpdate = false
                self?.workspace?.diagramEditor.selectNode(node)
                self?.shouldSendSelectionUpdate = true
            }
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        guard
            let node = workspace?.diagramEditor.selectedNode,
              /// update outline selection only if the parent of selected item match with expanded item
              node.parent === notification.userInfo?["NSObject"] as? DiagramNode else {
            return
        }
        /// select active node under collapsed parent only if its parent is expanding
        if outlineView.isItemExpanded(node.parent) {
            updateSelection(nodeID: node.id)
        }
    }

    func outlineViewItemDidCollapse(_ notification: Notification) {}

    /// Finds and selects an ``Item`` from an array of ``Item`` and their `children` based on the `id`.
    /// - Parameters:
    ///   - id: the id of the item item
    ///   - collection: the array to search for
    ///   - forcesReveal: The boolean to indicates whether or not it should force to reveal the selected node.
    func select(by id: UUID, forcesReveal: Bool) {
        guard let node = workspace?.diagramEditor.findNode(by: id) else {
            return
        }
        // If the user has set "Reveal node on selection change" to on or it is forced to reveal,
        // we need to reveal the item before selecting the row.
        if forcesReveal {
            reveal(node)
        }
        let row = outlineView.row(forItem: node)
        if row == -1 {
            outlineView.deselectRow(outlineView.selectedRow)
        }
        shouldSendSelectionUpdate = false
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        shouldSendSelectionUpdate = true
    }

    /// Reveals the given `node` in the outline view by expanding all the parent nodes.
    /// If the node is not found, it will present an alert saying so.
    public func reveal(_ node: DiagramNode) {
        if let parent = node.parent {
            expandParent(node: parent)
        }
        let row = outlineView.row(forItem: node)
        shouldSendSelectionUpdate = false
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        shouldSendSelectionUpdate = true

        if row < 0 {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString(
                "Could not find node",
                comment: "Could not find node"
            )
            alert.runModal()
            return
        } else {
            let visibleRect = scrollView.contentView.visibleRect
            let visibleRows = outlineView.rows(in: visibleRect)
            guard !visibleRows.contains(row) else {
                /// in case that the selected node is not fully visible (some parts are out of the visible rect),
                /// `scrollRowToVisible(_:)` method brings the node where it can be fully visible.
                outlineView.scrollRowToVisible(row)
                return
            }
            let rowRect = outlineView.rect(ofRow: row)
            let centerY = rowRect.midY - (visibleRect.height / 2)
            let center = NSPoint(x: 0, y: centerY)
            /// `scroll(_:)` method alone doesn't bring the selected node to the center in some cases.
            /// calling `scrollRowToVisible(_:)` method before it makes the node reveal in the center more correctly.
            outlineView.scrollRowToVisible(row)
            outlineView.scroll(center)
        }
    }

    /// Method for recursively expanding a node's parents.
    private func expandParent(node: DiagramNode) {
        if let parent = node.parent as DiagramNode? {
            expandParent(node: parent)
        }
        outlineView.expandItem(node)
    }

    /// Adds a tooltip to the node row.
    func outlineView( // swiftlint:disable:this function_parameter_count
        _ outlineView: NSOutlineView,
        toolTipFor cell: NSCell,
        rect: NSRectPointer,
        tableColumn: NSTableColumn?,
        item: Any,
        mouseLocation: NSPoint
    ) -> String {
        if let node = item as? DiagramNode {
            return node.name
        }
        return ""
    }
}
