import Foundation

class NavigatorSidebarViewModel: ObservableObject {
    @Published var selectedTab: NavigatorTab? = .project
    @Published var tabItems: [NavigatorTab] = []

    func setNavigatorTab(tab newTab: NavigatorTab) {
        selectedTab = newTab
    }
}
