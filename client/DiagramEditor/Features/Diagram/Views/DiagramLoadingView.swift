import SwiftUI

struct DiagramLoadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ProgressView()
            Text("Loading...")
            Spacer()
        }
    }
}
