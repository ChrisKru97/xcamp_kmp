import SwiftUI
import shared

struct PlaceDetailView: View {
    let placeUid: String
    @State private var state: ContentState<Place> = .loading

    var body: some View {
        Group {
            switch state {
            case .loading:
                LoadingView()
            case .loaded(let place, _):
                EntityDetailView(
                    entity: place,
                    config: .place
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        mapsButton(place)
                    }
                }
            case .refreshing(let place):
                EntityDetailView(
                    entity: place,
                    config: .place
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        mapsButton(place)
                    }
                }
            case .error:
                ErrorView {
                    await loadPlace()
                }
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
            let result = try await ServiceFactory.shared.getPlacesService().getPlaceById(uid: placeUid)
            guard !Task.isCancelled else { return }
            if let place = result as? Place {
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    state = .loaded(place)
                }
            } else {
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    state = .error(NSError(domain: "PlaceDetailView", code: 404, userInfo: [
                        NSLocalizedDescriptionKey: Strings.Places.shared.PLACE_NOT_FOUND
                    ]))
                }
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                state = .error(error)
            }
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
