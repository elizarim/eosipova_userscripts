import SwiftUI

final class DiagramEditor: ObservableObject, Identifiable {
    let id = UUID()
    
    var rootNode: DiagramNode? {
        didSet {
            updateRootCircleNode()
            selectNode(nil)
            version += 1
        }
    }
    @Published private(set) var rootCircleNode: DiagramCircleNode?
    @Published private(set) var selectedNode: DiagramNode?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var version: Int = 0

    private var branchShapeAttributes: [CircleShapeAttributes] = []
    private let delegates: NSHashTable<AnyObject> = .weakObjects()
    weak var view: DiagramEditorView?
    private var isExportMode: Bool = false

    init(selectedNode: DiagramNode? = nil) {
        self.selectedNode = selectedNode
    }

    func renderImage() -> NSImage? {
        isExportMode = true
        defer { isExportMode = false }
        return view?.renderImage()
    }

    func findNode(by nodeID: DiagramNode.ID) -> DiagramNode? {
        rootNode?.findNode(by: nodeID)
    }

    func selectNode(_ node: DiagramNode?) {
        guard selectedNode != node else { return }
        self.selectedNode = node
        version += 1
    }

    func deselectNode(_ node: DiagramNode) {
        guard selectedNode == node else { return }
        selectedNode = nil
        version += 1
    }

    func renameNode(_ node: DiagramNode, newName: String) {
        node.rename(newName: newName)
        version += 1
        notifyDelegates(node: node, isRecursive: false)
    }

    func setSize(_ size: Double, for node: LeafDiagramNode) {
        node.size = size
        updateRootCircleNode()
        version += 1
    }

    func resolveNSFillColor(for node: DiagramNode) -> NSColor? {
        return resolveShapeAttributes(for: node).fillColor
    }

    func resolveShapeAttributes(for node: DiagramNode) -> CircleShapeAttributes {
        var attributes = node.isBranch
            ? branchShapeAttributes[node.nestingLevel]
            : Constants.leafAttributes
        if let color = node.nsFillColor {
            attributes.fillColor = color
        }
        return attributes
    }

    func setColor(_ color: Color?, for node: DiagramNode) {
        guard color != node.swiftFillColor else {
            return
        }
        node.swiftFillColor = color
        version += 1
        notifyDelegates(node: node, isRecursive: false)
    }

    func setNameVisibility(_ visible: Bool, for node: DiagramNode) {
        guard visible != !node.isNameHidden else {
            return
        }
        node.isNameHidden = !visible
        version += 1
    }

    func addNode(_ node: DiagramNode, to parentNode: BranchDiagramNode) {
        parentNode.add(child: node)
        version += 1
        notifyDelegates(node: parentNode, isRecursive: true)
    }

    func deleteNode(_ node: DiagramNode) {
        guard let parentNode = node.parent else {
            return
        }
        parentNode.remove(child: node)
        if selectedNode == node {
            selectedNode = nil
        }
        version += 1
        notifyDelegates(node: parentNode, isRecursive: true)
    }

    /// Add an observer for editor events.
    func addDelegate(_ delegate: DiagramEditorDelegate) {
        delegates.add(delegate as AnyObject)
    }

    /// Remove an observer for editor events.
    func removeObserver(_ delegate: DiagramEditorDelegate) {
        delegates.remove(delegate as AnyObject)
    }

    // MARK: Private

    private func notifyDelegates(node: DiagramNode, isRecursive: Bool) {
        if isRecursive {
            updateRootCircleNode()
        }
        notifyDelegates(updates: [DiagramEditorUpdate(node: node, isRecursive: isRecursive)])
    }

    private func notifyDelegates(updates: [DiagramEditorUpdate]) {
        delegates.allObjects.forEach { delegate in
            guard let delegate = delegate as? DiagramEditorDelegate else {
                delegates.remove(delegate)
                return
            }
            delegate.diagramEditorUpdated(updates: updates)
        }
    }

    private func updateRootCircleNode() {
        guard let rootNode else {
            self.rootCircleNode = nil
            self.branchShapeAttributes = []
            return
        }
        let tree = DiagramInputNode(from: rootNode)
        let config = PackingConfig(padding: .fixed(value: 8.0), emptyRadius: 8)
        var circle = tree.pack(using: config)
        circle.center = Point(x: circle.radius, y: circle.radius)
        if branchShapeAttributes.count < rootNode.treeHeight {
            self.branchShapeAttributes = Self.generateBranchShapeAttributes(
                blendedWith: Constants.rootColor,
                count: max(rootNode.treeHeight, 10)
            )
        }
        self.rootCircleNode = circle
    }

    // MARK: Private

    private static func generateBranchShapeAttributes(blendedWith backgroundColor: NSColor, count: Int) -> [CircleShapeAttributes] {
        let blendingAlpha = 1.0 / CGFloat(count)
        var colors: [NSColor] = [backgroundColor.blend(with: Constants.leafColor, alpha: blendingAlpha)]
        for i in 1..<count {
            colors.append(colors[i - 1].blend(with: Constants.leafColor, alpha: blendingAlpha))
        }
        return colors.map { CircleShapeAttributes(fillColor: $0) }
    }
}

extension DiagramEditor: Hashable {
    static func == (lhs: DiagramEditor, rhs: DiagramEditor) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension DiagramEditor: CirclePackingViewDelegate {
    func shouldDrawChildren(of circle: DiagramCircleNode, context: CircleDrawingContext) -> Bool {
        true
    }

    func shapeAttributes(for circle: DiagramCircleNode, with context: CircleDrawingContext) -> CircleShapeAttributes {
        var attributes = resolveShapeAttributes(for: circle.diagramNode)
        if circle.diagramNode == selectedNode, !isExportMode {
            attributes.line = .init(color: Constants.accentColor, width: 2.0)
        }
        return attributes
    }

    func circlePackingViewDidClickedNode(_ clickedNode: DiagramNode) {
        if selectedNode == clickedNode {
            deselectNode(clickedNode)
        } else {
            selectNode(clickedNode)
        }
    }
}

struct DiagramEditorUpdate {
    var node: DiagramNode
    var isRecursive: Bool
}

protocol DiagramEditorDelegate: AnyObject {
    func diagramEditorUpdated(updates: [DiagramEditorUpdate])
}

protocol DiagramEditorView: AnyObject {
    func renderImage() -> NSImage?
}

private extension DiagramInputNode {
    init(from diagramNode: DiagramNode) {
        switch diagramNode {
        case let branch as BranchDiagramNode:
            self = .branch(payload: diagramNode, children: branch.children?.map(DiagramInputNode.init(from:)) ?? [])
        case let leaf as LeafDiagramNode:
            self = .leaf(payload: leaf)
        default:
            fatalError()
        }
    }
}

private extension DiagramNode {
    var nestingLevel: Int {
        var result = 0
        var parent = self.parent
        while parent != nil {
            result += 1
            parent = parent?.parent
        }
        return result
    }

    var treeHeight: Int {
        if let branch = self as? BranchDiagramNode, let children = branch.children {
            return 1 + (children.max(by: { $0.treeHeight < $1.treeHeight })?.treeHeight ?? 0)
        }
        return 1
    }
}

private extension NSColor {
    func blend(with color: NSColor, alpha: CGFloat) -> NSColor {
        let a = self.cgColor.components!
        let b = color.cgColor.components!
        let red   = a[0]*(1 - alpha) + alpha*b[0]
        let green = a[1]*(1 - alpha) + alpha*b[1]
        let blue  = a[2]*(1 - alpha) + alpha*b[2]
        let alpha = a[3]*(1 - alpha) + alpha*b[3]
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension DiagramEditor {
    enum Constants {
        static let leafAttributes: CircleShapeAttributes = .init(fillColor: leafColor)
        static let selectionAttributes: CircleShapeAttributes = .init(line: .init(color: accentColor, width: 2.0))

        static let rootColor: NSColor = .init(red: 1.0/255.0, green: 5.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        static let leafColor: NSColor = .init(red: 65.0/255.0, green: 161.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        static let accentColor: NSColor = .init(red: 253.0/255.0, green: 143.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    }
}
