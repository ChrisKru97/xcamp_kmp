import SwiftUI
import shared
import Kingfisher

enum PlacesState {
    case loading
    case loaded([Place])
    case error
}

@MainActor
class PlacesViewModel: ObservableObject {
    @Published private(set) var state: PlacesState = .loading
    @Published private(set) var arealImageURL: String? = nil

    func loadPlaces(service: PlacesService) async {
        state = .loading
        do {
            let places = try await service.getAllPlaces()
            arealImageURL = try? await service.getArealImageURL()
            state = .loaded(places)
        } catch {
            state = .error
        }
    }

    func refreshPlaces(service: PlacesService) async {
        KingfisherManager.shared.cache.clearMemoryCache()
        do {
            _ = try await service.refreshPlaces()
            await loadPlaces(service: service)
        } catch {
        }
    }
}
