import SwiftUI
import shared

struct MediaGrid: View {
    let links: [MediaLink]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(links, id: \.url) { link in
                LinkTile(item: link)
            }
        }
    }
}

#Preview {
    MediaGrid(links: [
        MediaLink(title: "YouTube", url: "https://youtube.com", type: MediaLinkType.youtube),
        MediaLink(title: "Spotify", url: "https://spotify.com", type: MediaLinkType.spotify),
        MediaLink(title: "Facebook", url: "https://facebook.com", type: MediaLinkType.facebook),
        MediaLink(title: "Instagram", url: "https://instagram.com", type: MediaLinkType.instagram)
    ])
    .padding()
    .background(Color.gray.opacity(0.1))
}
