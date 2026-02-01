import SwiftUI
import shared

struct EntityDetailView<T: EntityDetailRepresentable>: View {
    let entity: T
    let config: EntityDetailViewConfig

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                heroImage
                entityDescription
                Spacer(minLength: Spacing.xxl)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
    }

    private var heroImage: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageWithFallback(
                url: entity.imageUrlURL,
                fallbackIconName: config.fallbackIconName,
                height: config.heroHeight
            )
            .clipped()

            Text(entity.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .shadow(color: .black.opacity(1.0), radius: 12, x: 0, y: 6)
                .padding(Spacing.lg)
        }
    }

    private var entityDescription: some View {
        Group {
            if let description = entity.description_, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding()
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

struct EntityDetailViewConfig {
    let heroHeight: CGFloat
    let fallbackIconName: String

    static let place = EntityDetailViewConfig(
        heroHeight: 250,
        fallbackIconName: "photo"
    )

    static let speaker = EntityDetailViewConfig(
        heroHeight: 300,
        fallbackIconName: "person.fill"
    )
}
