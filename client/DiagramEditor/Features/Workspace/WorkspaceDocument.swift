import AppKit
import SwiftUI
import Combine
import Foundation

@objc(WorkspaceDocument)
final class WorkspaceDocument: NSDocument, ObservableObject {
    private var persistentURL: URL?
    private var persistentState: [String: Any] {
        get {
            let key = "diagramState-\(self.fileURL?.absoluteString ?? "")"
            return UserDefaults.standard.object(forKey: key) as? [String: Any] ?? [:]
        }
        set {
            let key = "diagramState-\(self.fileURL?.absoluteString ?? "")"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    let diagramEditor: DiagramEditor = .init()
    let cloudClient: CloudClient = .init(keychain: AppKeychain())
    let errorHandler: any AppErrorHandling = AppErrorHandler()
    private let notifier: WorkspaceDocumentNotifier = .init()
    private var cancellables = Set<AnyCancellable>()

    deinit {
        cancellables.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }

    func getFromPersistentState(_ key: WorkspaceStateKey) -> Any? {
        return persistentState[key.rawValue]
    }

    func addToPersistentState(key: WorkspaceStateKey, value: Any?) {
        if let value {
            persistentState.updateValue(value, forKey: key.rawValue)
        } else {
            persistentState.removeValue(forKey: key.rawValue)
        }
    }

    // MARK: NSDocument

    override static var autosavesInPlace: Bool { false }

    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        let windowController = AppWindowController(
            window: window,
            workspace: self
        )
        if let rectString = getFromPersistentState(.windowSize) as? String {
            window.setFrame(NSRectFromString(rectString), display: true, animate: false)
        } else {
            window.setFrame(NSRect(x: 0, y: 0, width: 1400, height: 900), display: true, animate: false)
            window.center()
        }
        self.addWindowController(windowController)
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: Set Up Workspace

    override func read(from url: URL, ofType typeName: String) throws {
        self.fileURL = url
        self.displayName = url.lastPathComponent
        try ensureURLPersisted()
        let persistentURL = try resolveFromPersistentURL()
        self.persistentURL = persistentURL
        _ = persistentURL.startAccessingSecurityScopedResource()
        if FileManager.default.fileExists(atPath: persistentURL.path),
           let json = try? Data(contentsOf: persistentURL),
           !json.isEmpty,
           let node = try? JSONDecoder().decode(BranchDiagramNode.self, from: json) {
            diagramEditor.rootNode = node
        } else {
            diagramEditor.rootNode = BranchDiagramNode(name: "")
        }
    }

    override func write(to url: URL, ofType typeName: String) throws {
        guard let rootNode = diagramEditor.rootNode as? BranchDiagramNode else {
            throw CocoaError(.fileWriteUnknown)
        }
        let rootNodeData = try JSONEncoder().encode(rootNode)
        try rootNodeData.write(to: url, options: .atomic)
    }

    private func ensureURLPersisted() throws {
        if getFromPersistentState(.bookmarkData) == nil {
            try saveBookmarkForFileURL()
        }
    }

    private func resolveFromPersistentURL() throws -> URL {
        guard fileURL != nil else {
            throw CocoaError(.fileNoSuchFile)
        }
        let bookmarkData = getFromPersistentState(.bookmarkData) as! Data
        var bookmarkDataIsStale = false
        let persistentURL = try URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &bookmarkDataIsStale
        )
        return persistentURL
    }

    private func saveBookmarkForFileURL() throws {
        guard let fileURL else {
            throw CocoaError(.fileNoSuchFile)
        }
        let bookmarkData = try fileURL.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        addToPersistentState(key: .bookmarkData, value: bookmarkData)
    }

    // MARK: Close Workspace

    override func close() {
        super.close()
        persistentURL?.stopAccessingSecurityScopedResource()
        cancellables.forEach { $0.cancel() }
    }
}
