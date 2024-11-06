import AppKit
import SwiftUI

extension AppWindowController {
    func setupToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.titleVisibility = .hidden
        self.window?.toolbarStyle = .unifiedCompact
        self.window?.titlebarSeparatorStyle = .automatic
        self.window?.toolbar = toolbar
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .flexibleSpace,
            .sidebarTrackingSeparator,
            .diagramTitleItem,
            .flexibleSpace,
            .commitDiagramItem,
            .exportDiagramItem,
            .itemListTrackingSeparator,
            .flexibleSpace,
            .toggleLastSidebarItem
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleFirstSidebarItem,
            .sidebarTrackingSeparator,
            .flexibleSpace,
            .itemListTrackingSeparator,
            .toggleLastSidebarItem,
            .diagramTitleItem,
            .commitDiagramItem,
            .exportDiagramItem,
        ]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .itemListTrackingSeparator:
            guard let splitViewController else { return nil }
            return NSTrackingSeparatorToolbarItem(
                identifier: .itemListTrackingSeparator,
                splitView: splitViewController.splitView,
                dividerIndex: 1
            )
        case .toggleFirstSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleFirstSidebarItem)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = " Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleFirstPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))
            return toolbarItem
        case .toggleLastSidebarItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleLastSidebarItem)
            toolbarItem.label = "Inspector Sidebar"
            toolbarItem.paletteLabel = "Inspector Sidebar"
            toolbarItem.toolTip = "Hide or show the Inspectors"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.toggleLastPanel)
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.trailing",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))
            return toolbarItem
        case .diagramTitleItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: .diagramTitleItem)
            let view = NSHostingView(
                rootView: AppDocumentTitleView(workspace: workspace!)
            )
            toolbarItem.view = view
            return toolbarItem
        case .commitDiagramItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.commitDiagramItem)
            toolbarItem.label = "Commit Diagram"
            toolbarItem.paletteLabel = "Commit Diagram"
            toolbarItem.toolTip = "Save diagram in the cloud"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.commitDiagram)
            toolbarItem.image = NSImage(
                systemSymbolName: "icloud.and.arrow.up.fill",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .medium))
            toolbarItem.autovalidates = false
            toolbarItem.isEnabled = workspace?.cloudClient.account != nil
            commitDiagramToolbarItem = toolbarItem
            return toolbarItem
        case .exportDiagramItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.exportDiagramItem)
            toolbarItem.label = "Export Diagram"
            toolbarItem.paletteLabel = "Export Diagram"
            toolbarItem.toolTip = "Export diagram as an image"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(self.exportDiagram)
            toolbarItem.image = NSImage(
                systemSymbolName: "photo.fill",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .medium))
            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    @objc
    func toggleFirstPanel() {
        guard let firstSplitView = splitViewController?.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
        splitViewController?.saveNavigatorCollapsedState(isCollapsed: firstSplitView.isCollapsed)
    }

    @objc
    func toggleLastPanel() {
        guard let lastSplitView = splitViewController?.splitViewItems.last else {
            return
        }
        NSAnimationContext.runAnimationGroup { _ in
            lastSplitView.animator().isCollapsed.toggle()
        }
        splitViewController?.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
    }

    @objc
    func commitDiagram() {
        openCloudCommitView(self)
    }

    @objc
    func exportDiagram() {
        exportDocument(self)
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let diagramTitleItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("TitleItem")
    static let exportDiagramItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ExportDiagramItem")
    static let commitDiagramItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("CommitDiagramItem")
}
