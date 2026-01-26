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
        .navigationTitle(entity.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .applyIf(config.hideToolbar) { view in
            view.modifier(iOS16ToolbarHiddenModifier())
        }
    }

    private var heroImage: some View {
        AsyncImageWithFallback(
            url: entity.imageUrlURL,
            fallbackIconName: config.fallbackIconName,
            height: config.heroHeight
        )
    }

    private var entityDescription: some View {
        Group {
            if let description = entity.description_, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding()
                    .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

struct EntityDetailViewConfig {
    let heroHeight: CGFloat
    let fallbackIconName: String
    let hideToolbar: Bool

    static let place = EntityDetailViewConfig(
        heroHeight: 250,
        fallbackIconName: "photo",
        hideToolbar: false
    )

    static let speaker = EntityDetailViewConfig(
        heroHeight: 300,
        fallbackIconName: "person.fill",
        hideToolbar: false
    )
}
