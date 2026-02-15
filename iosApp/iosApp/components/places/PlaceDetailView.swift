import SwiftUI
import shared

struct PlaceDetailView: View {
    let placeUid: String
    @State private var state: ContentState<Place> = .loading

    var placesService: PlacesService { ServiceFactory.shared.getPlacesService() }

    var body: some View {
        EmptyView()
            .switchingContent(state) { place, _ in
                EntityDetailView(
                    entity: place,
                    config: .place
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        mapsButton(place)
                    }
                }
            } error: { error in
                ErrorView(error: error) {
                    await loadPlace()
                }
            }
            .task {
                await loadPlace()
            }
    }

    @ViewBuilder
    private func mapsButton(_ place: Place) -> some View {
        if place.latitude != nil && place.longitude != nil {
            Button {
                if let lat = place.latitude, let lon = place.longitude {
                    MapOpener.shared.openMap(latitude: lat.doubleValue, longitude: lon.doubleValue, name: place.name)
                }
            } label: {
                Image(systemName: "map.fill")
            }
        }
    }

    private func loadPlace() async {
        do {
            let result = try await placesService.getPlaceById(uid: placeUid)
            guard !Task.isCancelled else { return }
            if let place = result as? Place {
                state = .loaded(place)
            } else {
                state = .error(AppError.notFound)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }
}

// MARK: - Previews

#Preview("Place Detail View - With Description") {
    PlaceDetailView(placeUid: "test")
        .preferredColorScheme(.dark)
}

#Preview("Place Detail View - Without Description") {
    PlaceDetailView(placeUid: "test2")
        .preferredColorScheme(.light)
}

#Preview("Place Detail View - Without Location") {
    PlaceDetailView(placeUid: "test3")
        .preferredColorScheme(.dark)
}
