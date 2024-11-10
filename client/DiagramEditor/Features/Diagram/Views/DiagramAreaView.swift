import SwiftUI

struct DiagramAreaView: View {
    @ObservedObject var editor: DiagramEditor

    var editorSide: Double { 2 * (editor.rootCircleNode?.radius ?? .zero) }

    init(diagramEditor: DiagramEditor) {
        self.editor = diagramEditor
    }

    var body: some View {
        VStack {
            if editor.isLoading {
                DiagramLoadingView()
            } else {
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    DiagramView()
                        .id(editor.version)
                        .frame(width: editorSide, height: editorSide)
//                        .overlay(Color.white.opacity(0.001))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
