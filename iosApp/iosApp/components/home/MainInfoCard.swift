import SwiftUI
import shared

struct MainInfoCard: View {
    let infoText: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.primary)

            Text(infoText)
                .foregroundColor(.secondary)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .backport.glassEffect(.regular)
    }
}

#Preview("Main info") {
    MainInfoCard(infoText: "Test\nAhoj\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also")
        .padding()
        .background(.background)
}
