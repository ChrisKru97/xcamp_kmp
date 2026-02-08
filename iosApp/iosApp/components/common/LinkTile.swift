import SwiftUI
import shared

struct LinkTile<T: LinkData>: View {
    let item: T

    var body: some View {
        Button {
            guard !item.url.isEmpty else { return }
            UrlOpener.shared.openUrl(url: item.url)
        } label: {
            tileContent
        }
        .scaleButton()
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
        .frame(height: 80)
        .card()
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
