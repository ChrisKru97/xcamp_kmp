import SwiftUI
import shared

struct PlaceDetailView: View {
    let placeUid: String
    @Environment(\.placesService) private var placesService
    @State private var place: Place?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let place = place {
                EntityDetailView(
                    entity: place,
                    config: .place
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        mapsButton(place)
                    }
                }
            } else if isLoading {
                ProgressView()
            } else {
                Text("Place not found")
            }
        }
        .task {
            await loadPlace()
        }
    }

    private func loadPlace() async {
        guard place == nil else { return }
        place = try? await placesService.getPlaceById(uid: placeUid)
        isLoading = false
    }

    @ViewBuilder
    private func mapsButton(_ place: Place) -> some View {
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
    PlaceDetailView(placeUid: "test")
        .environment(\.placesService, PlacesService())
        .preferredColorScheme(.dark)
}

#Preview("Place Detail View - Without Description") {
    PlaceDetailView(placeUid: "test2")
        .environment(\.placesService, PlacesService())
        .preferredColorScheme(.light)
}

#Preview("Place Detail View - Without Location") {
    PlaceDetailView(placeUid: "test3")
        .environment(\.placesService, PlacesService())
        .preferredColorScheme(.dark)
}
