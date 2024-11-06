import SwiftUI

struct AppDocumentTitleView: View {
    private var workspace: WorkspaceDocument
    private var title: String { workspace.displayName }

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        Text(title)
            .font(.headline)
            .frame(height: 16)
    }
}
