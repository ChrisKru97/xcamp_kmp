import SwiftUI
import shared

struct PlaceListItem: View, Equatable {
    let place: Place

    static func == (lhs: PlaceListItem, rhs: PlaceListItem) -> Bool {
        lhs.place.uid == rhs.place.uid
    }

    var body: some View {
        ImageNameCard(
            name: place.name,
            imageUrl: place.imageUrlURL,
            fallbackIconName: "photo",
            imageShape: .roundedRect
        )
    }
}

// MARK: - Previews

#Preview("Place List Item") {
    PlaceListItem(place: Place(
        uid: "test",
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
        uid: "test2",
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
