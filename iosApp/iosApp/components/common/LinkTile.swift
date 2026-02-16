import SwiftUI
import shared

struct LinkTile<T: LinkData>: View {
    let item: T

    var body: some View {
        Button {
            guard !item.url.isEmpty else { return }
            logMediaLinkClick()
            // For address links, use MapOpener which has proper fallback logic -- TODO MOVE IT
            if let infoLink = item as? InfoLink, infoLink.type == InfoLinkType.address {
                MapOpener.shared.openMap(latitude: 49.7158, longitude: 18.5934, name: "Smilovice 79")
            } else {
                UrlOpener.shared.openUrl(url: item.url)
            }
        } label: {
            tileContent
        }
        .glassButton()
    }

    private func logMediaLinkClick() {
        let linkType: String
        if let infoLink = item as? InfoLink {
            linkType = infoLink.type.name
        } else if let mediaLink = item as? MediaLink {
            linkType = mediaLink.type.name
        } else {
            linkType = "unknown"
        }

        Analytics.shared.logEvent(name: AnalyticsEvents.shared.MEDIA_LINK_CLICK, parameters: [
            AnalyticsEvents.shared.PARAM_LINK_TYPE: linkType,
            AnalyticsEvents.shared.PARAM_URL: item.url
        ])
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
