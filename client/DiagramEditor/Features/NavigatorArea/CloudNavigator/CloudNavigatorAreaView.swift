import SwiftUI

struct CloudNavigatorAreaView: View {
    @EnvironmentObject var workspace: WorkspaceDocument

    var body: some View {
        CloudNavigatorView(workspace: workspace)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CloudNavigatorToolbarBottom(workspace)
            }
    }
}
