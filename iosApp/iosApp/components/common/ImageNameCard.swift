import SwiftUI

struct ImageNameCard: View, Equatable {
    let name: String
    let imageUrl: URL?
    let fallbackIconName: String
    let imageShape: ImageShape

    enum ImageShape {
        case roundedRect
        case circle
    }

    static func == (lhs: ImageNameCard, rhs: ImageNameCard) -> Bool {
        lhs.name == rhs.name &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.fallbackIconName == rhs.fallbackIconName &&
        lhs.imageShape == rhs.imageShape
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            imageView
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
    }

    @ViewBuilder
    private var imageView: some View {
        let content = AsyncImageWithFallback(
            url: imageUrl,
            fallbackIconName: fallbackIconName,
            size: CGSize(width: 120, height: 120)
        )

        if imageShape == .circle {
            content.clipShape(Circle())
        } else {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }
}

// MARK: - Previews

#Preview("Image Name Card - Rounded Rect") {
    ImageNameCard(
        name: "Test Place",
        imageUrl: nil,
        fallbackIconName: "photo",
        imageShape: .roundedRect
    )
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Image Name Card - Circle") {
    ImageNameCard(
        name: "Jan Novák",
        imageUrl: nil,
        fallbackIconName: "person.fill",
        imageShape: .circle
    )
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}
