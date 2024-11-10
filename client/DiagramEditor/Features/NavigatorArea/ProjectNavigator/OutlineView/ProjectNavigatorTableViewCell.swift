import SwiftUI

protocol OutlineTableViewCellDelegate: AnyObject {
    func renameNode(_ node: DiagramNode, newName: String)
}

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class ProjectNavigatorTableViewCell: DiagramNodeTableViewCell {
    private weak var delegate: OutlineTableViewCellDelegate?

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the user's preferences.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - node: The node the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the file name.
    init(
        frame frameRect: NSRect,
        node: DiagramNode?,
        isEditable: Bool = true,
        delegate: OutlineTableViewCellDelegate? = nil
    ) {
        super.init(frame: frameRect, node: node, isEditable: isEditable)
        self.delegate = delegate
    }

    /// *Not Implemented*
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        fatalError()
    }

    /// *Not Implemented*
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let node else { return }
        delegate?.renameNode(node, newName: textField?.stringValue ?? "")
    }
}
