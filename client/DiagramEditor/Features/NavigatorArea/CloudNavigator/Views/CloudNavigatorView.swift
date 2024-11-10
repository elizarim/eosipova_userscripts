import SwiftUI

struct CloudNavigatorView: View {
    private let workspace: WorkspaceDocument
    @ObservedObject private var cloudClient: CloudClient

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.cloudClient = workspace.cloudClient
    }

    var body: some View {
        if cloudClient.account == nil {
            Text("Sign in required")
                .padding()
                .frame(minHeight: .zero, maxHeight: .infinity)
        } else {
            CloudNavigatorHistoryView(
                cloudClient: cloudClient,
                diagramEditor: workspace.diagramEditor
            )
        }
    }
}
