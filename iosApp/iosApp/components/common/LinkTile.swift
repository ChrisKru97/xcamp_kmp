import SwiftUI
import shared

struct LinkTile<T: LinkData>: View {
    let item: T

    @State private var isPressed = false

    var body: some View {
        Button {
            isPressed.toggle()
            guard !item.url.isEmpty else { return }
            UrlOpener.shared.openUrl(url: item.url)
        } label: {
            tileContent
        }
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder
    private var tileContent: some View {
            VStack(spacing: Spacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.8))

                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.sm)
        .card()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview("Info Link") {
    LinkTile(item: InfoLink(
        title: "Telefon",
        url: "tel:+420732378740",
        type: InfoLinkType.phone
    ))
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Media Link") {
    LinkTile(item: MediaLink(
        title: "YouTube",
        url: "https://youtube.com",
        type: MediaLinkType.youtube
    ))
    .padding()
    .background(Color.gray.opacity(0.1))
}
