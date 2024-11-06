import SwiftUI

struct CloudNavigatorHistoryView: View {
    @State private var isFetchingHistory: Bool = false
    @State private var syncErrorDetail: String?
    @ObservedObject private(set) var cloudClient: CloudClient
    var diagramEditor: DiagramEditor

    var body: some View {
        VStack {
            if let history = cloudClient.history, !history.isEmpty {
                List() {
                    ForEach(history) { diagram in
                        CloudDiagramView(diagram, cloudClient)
                            .listRowSeparator(.hidden)
                    }
                }
            } else if isFetchingHistory {
                VStack(spacing: 10) {
                    Spacer()
                    Text("Loading history...")
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                    Spacer()
                }
            } else if cloudClient.account != nil, let syncErrorDetail, !syncErrorDetail.isEmpty {
                Text(syncErrorDetail)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(minHeight: .zero, maxHeight: .infinity)
            } else {
                Text("History is empty")
                    .padding()
                    .frame(minHeight: .zero, maxHeight: .infinity)
            }
        }
        .task {
            guard !isFetchingHistory, let rootNode = diagramEditor.rootNode else {
                return
            }
            syncErrorDetail = nil
            isFetchingHistory = true
            do {
                try await cloudClient.updateDiagramHistory(contentID: rootNode.id)
            } catch {
                handleRequestError(error)
            }
            isFetchingHistory = false
        }
    }

    private func handleRequestError(_ error: Error) {
        if let apiError = error as? CloudClient.APIError {
            syncErrorDetail = apiError.reason
        } else {
            syncErrorDetail = error.localizedDescription
        }
    }
}
