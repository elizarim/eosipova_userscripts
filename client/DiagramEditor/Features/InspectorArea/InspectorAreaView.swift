import SwiftUI

struct InspectorAreaView: View {
    @ObservedObject var editor: DiagramEditor
    @State private var nodeSize: Double
    @State private var nodeColor: Color?
    @State private var nodeNameVisible: Bool

    init(diagramEditor: DiagramEditor) {
        self.editor = diagramEditor
        self.nodeSize = (diagramEditor.selectedNode as? LeafDiagramNode)?.size ?? 0
        self.nodeColor = diagramEditor.selectedNode?.swiftFillColor
        self.nodeNameVisible = !(diagramEditor.selectedNode?.isNameHidden ?? true)
    }

    var body: some View {
        VStack {
            Group {
                if let node = editor.selectedNode {
                    Form {
                        Section("Identity and Type") {
                            fileNameField
                        }
                        Section("Attributes") {
                            if !node.isBranch {
                                sizeAttribute
                            }
                            colorAttribute
                            nameVisibilityToggle
                        }
                        .id(node.id)
                    }
                } else {
                    ContentUnavailableView("No Selection")
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: editor.selectedNode) { node in
            updateAttributes(of: node)
        }
    }

    @ViewBuilder private var fileNameField: some View {
        if let node = editor.selectedNode {
            LabeledContent("Name") {
                Text(node.name)
            }
        }
    }

    @ViewBuilder private var sizeAttribute: some View {
        if let node = editor.selectedNode as? LeafDiagramNode {
            LabeledContent("Size") {
                Stepper(
                    "",
                    value: Binding<Double>(
                        get: { nodeSize },
                        set: { nodeSize = $0 }
                    ),
                    in: 0...Double(Int.max),
                    step: 1,
                    format: .number
                )
                .labelsHidden()
            }
            .onChange(of: nodeSize) { newValue in
                editor.setSize(newValue, for: node)
            }
        }
    }

    @ViewBuilder private var colorAttribute: some View {
        if let node = editor.selectedNode {
            InspectorColorPicker(
                "Fill Color",
                color: Binding<Color>(
                    get: { Color(nsColor: editor.resolveNSFillColor(for: node) ?? .clear) },
                    set: { nodeColor = $0 }
                )
            )
            .onChange(of: nodeColor) { newValue in
                editor.setColor(newValue, for: node)
            }
        }
    }

    @ViewBuilder private var nameVisibilityToggle: some View {
        if let node = editor.selectedNode {
            Toggle("Show Name", isOn: $nodeNameVisible)
                .onChange(of: nodeNameVisible) { newValue in
                    editor.setNameVisibility(newValue, for: node)
                }
        }
    }

    private func updateAttributes(of node: DiagramNode?) {
        self.nodeSize = (node as? LeafDiagramNode)?.size ?? 0
        self.nodeColor = node?.swiftFillColor
        self.nodeNameVisible = !(node?.isNameHidden ?? true)
    }
}
