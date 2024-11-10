import SwiftUI

class DiagramNodeTableViewCell: StandardTableViewCell {
    weak var node: DiagramNode?

    var changeLabelLargeWidth: NSLayoutConstraint!
    var changeLabelSmallWidth: NSLayoutConstraint!

    /// Initializes the `OutlineTableViewCell` with an `icon` and `label`
    /// Both the icon and label will be colored, and sized based on the node's properties.
    /// - Parameters:
    ///   - frameRect: The frame of the cell.
    ///   - node: The node item the cell represents.
    ///   - isEditable: Set to true if the user should be able to edit the node name.
    init(frame frameRect: NSRect, node: DiagramNode?, isEditable: Bool = true) {
        super.init(frame: frameRect, isEditable: isEditable)
        self.node = node
        if let node {
            addIcon(node: node)
        }
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)
        label.delegate = self
    }

    func addIcon(node: DiagramNode) {
        imageView?.image = node.nsIcon
        imageView?.contentTintColor = node.nsFillColor
        textField?.stringValue = node.name
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

    /// Returns the font size for the current row height. Defaults to `13.0`
    private var fontSize: Double {
        switch self.frame.height {
        case 20: return 11
        case 22: return 13
        case 24: return 14
        default: return 13
        }
    }

    deinit {
        toolTip = nil
    }
}

extension DiagramNodeTableViewCell: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let node else { return }
        workspace?.diagramEditor.renameNode(node, newName: textField?.stringValue ?? "")
        workspace?.diagramEditor.selectNode(node)
    }
}
