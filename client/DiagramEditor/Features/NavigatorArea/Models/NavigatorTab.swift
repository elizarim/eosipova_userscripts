import SwiftUI

enum NavigatorTab: AreaTab {
    case project
    case cloud

    var systemImage: String {
        switch self {
        case .project:
            return "folder"
        case .cloud:
            return "cloud"
        }
    }

    var id: String {
        return title
    }

    var title: String {
        switch self {
        case .project:
            return "Project"
        case .cloud:
            return "Cloud"
        }
    }

    var body: some View {
        switch self {
        case .project:
            ProjectNavigatorView()
        case .cloud:
            CloudNavigatorAreaView()
        }
    }
}
