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

    @ViewBuilder
    private var entityDescription: some View {
        if let description = entity.description_, !description.isEmpty {
            Text(description)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(.horizontal, Spacing.lg)
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

// MARK: - Previews

#Preview("EntityDetailView - Place") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            EntityDetailView(
                entity: Place(
                    uid: "test-place",
                    name: "Test Place",
                    description: "This is a test description for a place.",
                    priority: 1,
                    latitude: 50.0,
                    longitude: 14.0,
                    image: nil,
                    imageUrl: nil
                ),
                config: .place
            )
        }
    } else {
        EntityDetailView(
            entity: Place(
                uid: "test-place",
                name: "Test Place",
                description: "This is a test description for a place.",
                priority: 1,
                latitude: 50.0,
                longitude: 14.0,
                image: nil,
                imageUrl: nil
            ),
            config: .place
        )
    }
}

#Preview("EntityDetailView - Speaker") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            EntityDetailView(
                entity: Speaker(
                    uid: "test-speaker",
                    name: "Test Speaker",
                    description: "This is a test description for a speaker.",
                    priority: 1,
                    image: nil,
                    imageUrl: nil
                ),
                config: .speaker
            )
        }
    } else {
        EntityDetailView(
            entity: Speaker(
                uid: "test-speaker",
                name: "Test Speaker",
                description: "This is a test description for a speaker.",
                priority: 1,
                image: nil,
                imageUrl: nil
            ),
            config: .speaker
        )
    }
}
