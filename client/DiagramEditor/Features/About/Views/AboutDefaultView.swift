import SwiftUI

struct AboutDefaultView: View {
    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    @Environment(\.colorScheme)
    var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.top, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                Text("DiagramEditor")
                    .foregroundColor(.primary)
                    .font(.system(size: 26, weight: .bold))
                Text("Version \(appVersion) (\(appBuild))")
                    .textSelection(.enabled)
                    .foregroundColor(Color(.tertiaryLabelColor))
                    .font(.body)
                    .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
        .padding(24)

        VStack {
            Spacer()
            VStack {
                VStack(spacing: 2) {
                    Text(Bundle.copyrightString ?? "")
                }
                .textSelection(.disabled)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(.tertiaryLabelColor))
                .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal)
    }
}
