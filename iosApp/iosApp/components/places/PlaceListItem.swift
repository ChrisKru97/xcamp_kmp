import SwiftUI
import shared
import Kingfisher

struct PlaceListItem: View, Equatable {
    let place: Place

    static func == (lhs: PlaceListItem, rhs: PlaceListItem) -> Bool {
        lhs.place.id == rhs.place.id
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            placeImage
            placeInfo
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
    }

    private var placeImage: some View {
        AsyncImageWithFallback(
            url: place.imageUrlURL,
            fallbackIconName: "photo",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    private var placeInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(place.name)
                .font(.headline)
                .foregroundColor(.primary)
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = place.description_, !description.isEmpty {
                Text(description.prefix(100) + (description.count > 100 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            if place.latitude != nil && place.longitude != nil {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(Strings.Places.shared.SHOW_ON_MAP)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Previews

#Preview("Place List Item - With Description") {
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
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Place List Item - Without Description") {
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
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}

#Preview("Place List Item - Long Description") {
    PlaceListItem(place: Place(
        id: "test3",
        name: "Place With Long Description",
        description: "This is a much longer description that should wrap nicely. It contains multiple lines of text describing the place in detail.",
        priority: 3,
        latitude: 50.5,
        longitude: 14.5,
        image: nil,
        imageUrl: nil
    ))
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
