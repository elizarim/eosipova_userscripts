import SwiftUI

struct CloudNavigatorToolbarBottom: View {
    private let workspace: WorkspaceDocument
    @ObservedObject private(set) var cloudClient: CloudClient

    init(_ workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.cloudClient = workspace.cloudClient
    }

    var body: some View {
        HStack(spacing: 5) {
            addNewNodeButton
            Spacer()
        }
        .padding(.horizontal, 5)
        .frame(height: 28, alignment: .leading)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var addNewNodeButton: some View {
        Menu {
            if cloudClient.account == nil {
                Button("Sign In...") {
                    NSApp.sendAction(#selector(AppWindowController.openCloudSignInView(_:)), to: nil, from: nil)
                }
                Button("Sign Up...") {
                    NSApp.sendAction(#selector(AppWindowController.openCloudSignUpView(_:)), to: nil, from: nil)
                }
            } else {
                Button("Commit Diagram...") {
                    NSApp.sendAction(#selector(AppWindowController.openCloudCommitView(_:)), to: nil, from: nil)
                }
                Divider()
                Button("Sign Out") {
                    cloudClient.signOut()
                }
            }
        } label: {}
        .background {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
    }
}
