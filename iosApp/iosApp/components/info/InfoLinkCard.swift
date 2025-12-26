import SwiftUI
import shared

struct InfoLinkCard: View {
    let link: InfoLink

    var body: some View {
        GlassCard {
            Button(action: { UrlOpener.shared.openUrl(url: link.url) }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: InfoIconProvider.iconName(for: link))
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Text(link.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
    }
}

@available(iOS 18, *)
#Preview("Phone", traits: .sizeThatFitsLayout) {
    InfoLinkCard(link: InfoLink(
        title: "Telefon: +420732378740",
        url: "tel:+420732378740",
        type: InfoLinkType.phone
    ))
    .padding(Spacing.md)
    .background(Color.background)
}

@available(iOS 18, *)
#Preview("Email", traits: .sizeThatFitsLayout) {
    InfoLinkCard(link: InfoLink(
        title: "info@xcamp.cz",
        url: "mailto:info@xcamp.cz",
        type: InfoLinkType.email
    ))
    .padding(Spacing.md)
    .background(Color.background)
}
