import Foundation
import Combine

class WorkspaceDocumentNotifier: ObservableObject {
    @Published var highlightedNode: DiagramNode?

    init() {
        highlightedNode = nil
    }
}
