import SwiftUI
import shared

enum PlacesState {
    case loading
    case loaded([Place])
    case error
}

@MainActor
class PlacesViewModel: ObservableObject {
    @Published private(set) var state: PlacesState = .loading

    func loadPlaces(service: PlacesService) async {
        state = .loading
        do {
            let places = try await service.getAllPlaces()
            state = .loaded(places)
        } catch {
            state = .error
        }
    }

    func refreshPlaces(service: PlacesService) async {
        do {
            _ = try await service.refreshPlaces()
            // On success, reload the places from local cache
            await loadPlaces(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
        }
    }
}
