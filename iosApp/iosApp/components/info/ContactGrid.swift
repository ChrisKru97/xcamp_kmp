import SwiftUI
import shared

struct ContactGrid: View {
    let links: [InfoLink]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(Strings.Info.shared.CONTACT_US)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, Spacing.xs)

            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(links, id: \.url) { link in
                    LinkTile(item: link)
                }
            }
        }
    }
}

#Preview {
    ContactGrid(links: [
        InfoLink(title: "Telefon", url: "tel:+420732378740", type: InfoLinkType.phone),
        InfoLink(title: "Email", url: "mailto:info@xcamp.cz", type: InfoLinkType.email),
        InfoLink(title: "Web", url: "https://xcamp.cz", type: InfoLinkType.web),
        InfoLink(title: "Mapa", url: "https://maps.google.com", type: InfoLinkType.map)
    ])
    .padding()
    .background(Color.gray.opacity(0.1))
}
