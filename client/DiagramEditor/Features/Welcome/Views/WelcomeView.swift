import SwiftUI
import AppKit
import Foundation

struct WelcomeView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    var controlActiveState

    @State var isHovering: Bool = false

    @State var isHoveringCloseButton: Bool = false

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let newDocument: () -> Void
    private let dismissWindow: () -> Void

    init(
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            mainContent
            dismissButton
        }
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)
            ZStack {
                if colorScheme == .dark {
                    Rectangle()
                        .frame(width: 104, height: 104)
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .blur(radius: 64)
                        .opacity(0.5)
                }
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
            }
            Text("DiagramEdit")
                .font(.system(size: 36, weight: .bold))
            Text("Version \(appVersion) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13.5))

            Spacer().frame(height: 40)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    WelcomeActionView(
                        iconName: "plus.square",
                        title: "Create New Diagram...",
                        action: {
                            newDocument()
                            dismissWindow()
                        }
                    )
                    WelcomeActionView(
                        iconName: "doc",
                        title: "Open Diagram...",
                        action: {
                            openDocument(nil, dismissWindow)
                        }
                    )
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 56)
        .padding(.bottom, 16)
        .frame(width: 460)
        .background(
            colorScheme == .dark
            ? Color(.black).opacity(0.2)
            : Color(.white).opacity(controlActiveState == .inactive ? 1.0 : 0.5)
        )
        .background(EffectView(.underWindowBackground, blendingMode: .behindWindow))
    }

    private var dismissButton: some View {
        Button(
            action: dismissWindow,
            label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(isHoveringCloseButton ? Color(.secondaryLabelColor) : Color(.tertiaryLabelColor))
            }
        )
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            withAnimation(.linear(duration: 0.15)) {
                isHoveringCloseButton = hover
            }
        }
        .padding(10)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
    }
}

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
