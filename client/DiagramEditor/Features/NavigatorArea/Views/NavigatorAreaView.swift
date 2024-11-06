import SwiftUI

struct NavigatorAreaView: View {
    @ObservedObject private var workspace: WorkspaceDocument
    @ObservedObject public var viewModel: NavigatorSidebarViewModel

    init(workspace: WorkspaceDocument, viewModel: NavigatorSidebarViewModel) {
        self.workspace = workspace
        self.viewModel = viewModel

        viewModel.tabItems = [.project, .cloud]
    }

    var body: some View {
        VStack {
            if let selection = viewModel.selectedTab {
                selection
            } else {
                ContentUnavailableView("No Selection")
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab)
                Divider()
            }
        }
        .environmentObject(workspace)
    }
}
