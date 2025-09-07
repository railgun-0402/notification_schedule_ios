import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.largeTitle)
            Text("予定がありません")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    EmptyStateView()
}
