import SwiftUI

struct CloudCommitView: View {
    @EnvironmentObject var workspace: WorkspaceDocument

    var diagram: DiagramNode? { workspace.diagramEditor.rootNode }
    var client: CloudClient { workspace.cloudClient }
    var dismiss: () -> Void

    @State var message = ""
    @State var isSendingRequest: Bool = false
    @State var errorAlertIsPresented: Bool = false
    @State var errorDetail: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    content: {
                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Commit")
                                    .font(.caption3)
                                    .foregroundColor(.secondary)
                                TextField("", text: $message)
                                    .multilineTextAlignment(.leading)
                                    .labelsHidden()
                            }
                        }
                        .disabled(isSendingRequest)
                    },
                    header: {
                        VStack(alignment: .center, spacing: 10) {
                            Text("Commit")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    },
                    footer: {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(isSendingRequest)
                            .controlSize(.large)
                            .frame(maxWidth: .infinity)

                            Button {
                                commit()
                            } label: {
                                Text("Commit")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(message.isEmpty || diagram == nil)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .alert(
                                Text("Unable to commit"),
                                isPresented: $errorAlertIsPresented
                            ) {
                                Button("OK") {
                                    errorAlertIsPresented.toggle()
                                }
                            } message: {
                                Text(errorDetail)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                )
            }
            .formStyle(.grouped)
            .background(Color.green)
            .scrollDisabled(true)
            .onSubmit {
                commit()
            }
        }
        .frame(width: 500)
    }

    @MainActor
    private func commit() {
        guard let diagram else { return }
        isSendingRequest = true
        Task { @MainActor in
            do {
                try await client.commitDiagram(diagram, message: message)
                try await client.updateDiagramHistory(contentID: diagram.id)
                dismiss()
            } catch {
                handleRequestError(error)
            }
            isSendingRequest = false
        }
    }

    private func handleRequestError(_ error: Error) {
        if let apiError = error as? CloudClient.APIError {
            errorDetail = apiError.reason
        } else {
            errorDetail = error.localizedDescription
        }
        errorAlertIsPresented.toggle()
    }
}
