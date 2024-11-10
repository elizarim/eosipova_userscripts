import Cocoa
import SwiftUI
import Combine
import UniformTypeIdentifiers

final class AppWindowController: NSWindowController, NSToolbarDelegate, ObservableObject, NSWindowDelegate {
    @Published var navigatorCollapsed = false
    @Published var inspectorCollapsed = false

    private var panelOpen = false
    weak var commitDiagramToolbarItem: NSToolbarItem?

    var observers: [NSKeyValueObservation] = []

    var workspace: WorkspaceDocument?
    var navigatorSidebarViewModel: NavigatorSidebarViewModel?
    private var cloudSignInWindow: NSWindow?
    private var cloudCommitWindow: NSWindow?

    internal var cancellables = [AnyCancellable]()

    var splitViewController: AppSplitViewController? {
        contentViewController as? AppSplitViewController
    }

    init(
        window: NSWindow?,
        workspace: WorkspaceDocument?
    ) {
        super.init(window: window)
        window?.delegate = self
        guard let workspace else { return }
        self.workspace = workspace
        guard let splitViewController = setupSplitView(with: workspace) else {
            fatalError("Failed to set up content view.")
        }

        // Previous:
        // An NSHostingController is used, so the root viewController of the window is a SwiftUI-managed one.
        // This allows us to use some SwiftUI features, like focusedSceneObject.
        // -----
        // let view = AppSplitView(controller: splitViewController).ignoresSafeArea()
        // contentViewController = NSHostingController(rootView: view)
        // -----
        //
        // New:
        // The previous decision led to a very jank split controller mechanism because SwiftUI's layout system is not
        // very compatible with AppKit's when it comes to the inspector/navigator toolbar & split view system.
        // -----
        contentViewController = splitViewController
        // -----

        observers = [
            splitViewController.splitViewItems.first!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.navigatorCollapsed = item.isCollapsed
            }),
            splitViewController.splitViewItems.last!.observe(\.isCollapsed, changeHandler: { [weak self] item, _ in
                self?.inspectorCollapsed = item.isCollapsed
            })
        ]

        setupToolbar()

        workspace.cloudClient.$account
            .sink(receiveValue: { [weak self] account in
                self?.commitDiagramToolbarItem?.isEnabled = account != nil
            })
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func saveDocument(_ sender: Any) {
        guard let workspace else { return }
        workspace.save(sender)
    }

    @IBAction func exportDocument(_ sender: Any) {
        guard
            let fileURL = chooseImageLocation(),
            let image = workspace?.diagramEditor.renderImage()
        else {
            return
        }
        do {
            try image.write(to: fileURL)
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @IBAction func openCloudCommitView(_ sender: Any) {
        guard let window = window, let workspace else {
            return
        }
        if let cloudCommitWindow, cloudCommitWindow.isVisible {
            cloudCommitWindow.makeKeyAndOrderFront(self)
            return
        }
        let commitWindow = NSWindow()
        self.cloudCommitWindow = commitWindow
        let commitView = CloudCommitView(dismiss: { [weak self, weak commitWindow] in
                guard let commitWindow else { return }
                self?.window?.endSheet(commitWindow)
            }
        ).environmentObject(workspace)
        let hostingView = NSHostingView(rootView: commitView)
        commitWindow.contentView = hostingView
        commitWindow.titlebarAppearsTransparent = true
        commitWindow.setContentSize(hostingView.intrinsicContentSize)
        window.beginSheet(commitWindow, completionHandler: nil)
    }

    @IBAction func openCloudSignUpView(_ sender: Any) {
        openCloudAuthView(mode: .signUp)
    }

    @IBAction func openCloudSignInView(_ sender: Any) {
        openCloudAuthView(mode: .signIn)
    }

    private func openCloudAuthView(mode: CloudAuthView.Mode) {
        guard let window = window, let cloudClient = workspace?.cloudClient else {
            return
        }
        if let cloudSignInWindow, cloudSignInWindow.isVisible {
            cloudSignInWindow.makeKeyAndOrderFront(self)
            return
        }
        let cloudSignInWindow = NSWindow()
        self.cloudSignInWindow = cloudSignInWindow
        let contentView = CloudAuthView(
            mode: mode,
            client: cloudClient,
            dismiss: { [weak self, weak cloudSignInWindow] in
                guard let cloudSignInWindow else { return }
                self?.window?.endSheet(cloudSignInWindow)
            }
        )
        let hostingView = NSHostingView(rootView: contentView)
        cloudSignInWindow.contentView = hostingView
        cloudSignInWindow.titlebarAppearsTransparent = true
        cloudSignInWindow.setContentSize(hostingView.intrinsicContentSize)
        window.beginSheet(cloudSignInWindow, completionHandler: nil)
    }

    private func setupSplitView(with workspace: WorkspaceDocument) -> AppSplitViewController? {
        guard let window else {
            assertionFailure("No window found for this controller. Cannot set up content.")
            return nil
        }
        let navigatorModel = NavigatorSidebarViewModel()
        navigatorSidebarViewModel = navigatorModel
        return AppSplitViewController(
            workspace: workspace,
            navigatorViewModel: navigatorModel,
            windowRef: window
        )
    }

    private func chooseImageLocation() -> URL? {
        guard let workspace, let fileURL = workspace.fileURL else { return nil }
        let dialogue = NSSavePanel()
        dialogue.title = "Export Image"
        dialogue.directoryURL = fileURL.deletingLastPathComponent()
        dialogue.allowedContentTypes = [UTType.png]
        if let fileName = fileURL.lastPathComponent.components(separatedBy: ".").first {
            dialogue.nameFieldStringValue = fileName + ".png"
        }
        if dialogue.runModal() == .OK {
            return dialogue.url
        } else {
            return nil
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()

        for _ in 0..<(splitViewController?.children.count ?? 0) {
            splitViewController?.removeChild(at: 0)
        }
        contentViewController?.removeFromParent()
        contentViewController = nil

        cloudCommitWindow?.close()
        cloudCommitWindow = nil
        cloudSignInWindow?.close()
        cloudSignInWindow = nil
        navigatorSidebarViewModel = nil
        workspace = nil
        return true
    }
}
