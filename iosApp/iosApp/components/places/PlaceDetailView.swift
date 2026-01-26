import SwiftUI
import shared

struct PlaceDetailView: View {
    let place: Place

    var body: some View {
        EntityDetailView(
            entity: place,
            config: .place
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                mapsButton
            }
        }
    }

    @ViewBuilder
    private var mapsButton: some View {
        if place.latitude != nil && place.longitude != nil {
            Button {
                if let lat = place.latitude, let lon = place.longitude {
                    openMaps(latitude: lat.doubleValue, longitude: lon.doubleValue, name: place.name)
                }
            } label: {
                Image(systemName: "map.fill")
            }
            .accessibilityLabel("Open in Maps")
        }
    }

    private func openMaps(latitude: Double, longitude: Double, name: String) {
        let region = "ll=\(latitude),\(longitude)"
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "http://maps.apple.com/?\(region)&q=\(encodedName)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Previews

#Preview("Place Detail View - With Description") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            PlaceDetailView(place: Place(
                id: "test",
                name: "Test Place",
                description: "This is a longer description that should wrap nicely. It can contain multiple lines of text describing the place in detail.",
                priority: 1,
                latitude: 50.0,
                longitude: 14.0,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.dark)
    } else {
        PlaceDetailView(place: Place(
            id: "test",
            name: "Test Place",
            description: "This is a longer description that should wrap nicely. It can contain multiple lines of text describing the place in detail.",
            priority: 1,
            latitude: 50.0,
            longitude: 14.0,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.dark)
    }
}

#Preview("Place Detail View - Without Description") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            PlaceDetailView(place: Place(
                id: "test2",
                name: "Place Without Description",
                description: nil,
                priority: 2,
                latitude: 50.5,
                longitude: 14.5,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.light)
    } else {
        PlaceDetailView(place: Place(
            id: "test2",
            name: "Place Without Description",
            description: nil,
            priority: 2,
            latitude: 50.5,
            longitude: 14.5,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.light)
    }
}

#Preview("Place Detail View - Without Location") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            PlaceDetailView(place: Place(
                id: "test3",
                name: "Place Without Location",
                description: "A place that has a description but no GPS coordinates.",
                priority: 3,
                latitude: nil,
                longitude: nil,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.dark)
    } else {
        PlaceDetailView(place: Place(
            id: "test3",
            name: "Place Without Location",
            description: "A place that has a description but no GPS coordinates.",
            priority: 3,
            latitude: nil,
            longitude: nil,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.dark)
    }
}
