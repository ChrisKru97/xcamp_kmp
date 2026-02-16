import SwiftUI

struct EmergencyPill: View {
    let icon: String
    let title: String
    let description: String

    @State private var isExpanded = false

    var body: some View {
        Button {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            pillContent
        }
        .glassButton()
    }

    @ViewBuilder
    private var pillContent: some View {
            VStack(alignment: .leading, spacing: isExpanded ? Spacing.sm : 0) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .leading)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, Spacing.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding()
    }
}

#Preview {
    VStack(spacing: 12) {
        EmergencyPill(
            icon: "cross.case.fill",
            title: "Medical Help",
            description: "Available at information desk 24/7. In case of any health issues please contact the service at information desk."
        )
        EmergencyPill(
            icon: "door.left.hand.open",
            title: "Leaving Camp",
            description: "In case of leaving camp please report this to information desk in advance."
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
