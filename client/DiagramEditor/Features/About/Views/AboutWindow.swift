import SwiftUI

struct AboutWindow: Scene {
    var body: some Scene {
        Window("", id: SceneID.about.rawValue) {
            AboutView()
        }
        .defaultSize(width: 530, height: 220)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
