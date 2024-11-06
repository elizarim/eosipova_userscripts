import SwiftUI

struct InspectorColorPicker<Content>: View where Content: View {
    @Binding var color: Color
    @State private var selectedColor: Color

    private let label: String
    private let content: Content?

    init(_ label: String, color: Binding<Color>, @ViewBuilder content: @escaping () -> Content) {
        self._color = color
        self.label = label
        self._selectedColor = State(initialValue: color.wrappedValue)
        self.content = content()
    }

    init(_ label: String, color: Binding<Color>) where Content == EmptyView {
        self.init(label, color: color) {
            EmptyView()
        }
    }

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 16) {
                content
                ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                    .labelsHidden()
            }
        }
        .onChange(of: selectedColor) { newValue in
            color = newValue
        }
    }
}
