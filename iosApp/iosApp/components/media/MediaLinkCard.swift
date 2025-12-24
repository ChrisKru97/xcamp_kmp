import SwiftUI
import shared

struct MediaLinkCard: View {
    let link: MediaLink

    var body: some View {
        GlassCard {
            Button(action: { UrlOpener.shared.openUrl(url: link.url) }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: MediaIconProvider.iconName(for: link))
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Text(link.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

@available(iOS 18, *)
#Preview("YouTube", traits: .sizeThatFitsLayout) {
    MediaLinkCard(link: MediaLink(
        title: "YouTube",
        url: "https://youtube.com",
        type: MediaLinkType.youtube
    ))
    .padding(Spacing.md)
    .background(Color.background)
}

@available(iOS 18, *)
#Preview("Spotify", traits: .sizeThatFitsLayout) {
    MediaLinkCard(link: MediaLink(
        title: "Spotify",
        url: "https://spotify.com",
        type: MediaLinkType.spotify
    ))
    .padding(Spacing.md)
    .background(Color.background)
}
