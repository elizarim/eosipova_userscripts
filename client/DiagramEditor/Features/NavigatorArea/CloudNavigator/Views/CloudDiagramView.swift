import SwiftUI

struct CloudDiagramView: View {
    @EnvironmentObject var workspace: WorkspaceDocument

    private let diagram: CloudDiagram
    private let cloudClient: CloudClient
    private var diagramEditor: DiagramEditor { workspace.diagramEditor }
    private var errorHandler: AppErrorHandling { workspace.errorHandler }

    init(_ diagram: CloudDiagram, _ cloudClient: CloudClient) {
        self.diagram = diagram
        self.cloudClient = cloudClient
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(diagram.createdAt.formatted())
                    .font(.system(size: 11))
                    .fontWeight(.bold)
                Text(diagram.message)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 1)
        }
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .contextMenu {
            Group {
                Button("Check Out") {
                    checkout()
                }
            }
        }
    }

    private func checkout() {
        Task { @MainActor in
            do {
                diagramEditor.rootNode = try await cloudClient.fetchDiagram(diagramID: diagram.id)
            } catch let error as CloudClient.APIError {
                errorHandler.showError(error, message: error.reason)
            } catch {
                errorHandler.showError(error, message: "Failed to checkout diagram")
            }
        }
    }
}
