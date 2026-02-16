import SwiftUI

struct CardUnavailableView: View {
    let message: String

    var body: some View {
        HStack {
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        CardUnavailableView(message: "Speaker Not Available")
        CardUnavailableView(message: "Place Not Available")
        CardUnavailableView(message: "Unknown Place")
    }
    .padding()
    .card()
}
