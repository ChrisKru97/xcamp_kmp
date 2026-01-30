import SwiftUI
import shared
import Kingfisher

struct PlaceListItem: View, Equatable {
    let place: Place

    static func == (lhs: PlaceListItem, rhs: PlaceListItem) -> Bool {
        lhs.place.id == rhs.place.id
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            placeImage
            Text(place.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
    }

    private var placeImage: some View {
        AsyncImageWithFallback(
            url: place.imageUrlURL,
            fallbackIconName: "photo",
            size: CGSize(width: 120, height: 120)
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }
}

// MARK: - Previews

#Preview("Place List Item") {
    PlaceListItem(place: Place(
        id: "test",
        name: "Test Place",
        description: "This is a test description for the place",
        priority: 1,
        latitude: 50.0,
        longitude: 14.0,
        image: nil,
        imageUrl: nil
    ))
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Place List Item - Without Image") {
    PlaceListItem(place: Place(
        id: "test2",
        name: "Another Place",
        description: nil,
        priority: 2,
        latitude: nil,
        longitude: nil,
        image: nil,
        imageUrl: nil
    ))
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}
