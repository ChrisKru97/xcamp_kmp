import SwiftUI
import shared
import Kingfisher

@MainActor
class PlacesViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[Place]> = .loading
    @Published private(set) var arealImageURL: String? = nil

    var placesService: PlacesService { ServiceFactory.shared.getPlacesService() }

    func loadPlaces(useCache: Bool = false) async {
        if !useCache {
            state = .loading
        }

        let hasCached = try? await placesService.hasCachedData()
        let isStale = try? await placesService.isDataStale(maxAgeMs: 3600000).boolValue ?? true

        if useCache, hasCached?.boolValue == true {
            let places = (try? await placesService.getAllPlaces()) ?? []
            let isStaleValue = isStale ?? true
            await loadArealImage()
            state = .loaded(places, isStale: isStaleValue)
        } else {
            await refreshAndHandleResult(isRefresh: false)
        }

        logScreenView()
    }

    private func logScreenView() {
        AnalyticsHelper.shared.logEvent(name: "screen_view", parameters: [
            "screen_name": "places",
            "tab_name": "places"
        ])
    }

    func refreshPlaces() async {
        KingfisherManager.shared.cache.clearMemoryCache()

        switch state {
        case .loaded(let places, _):
            state = .refreshing(places)
        default:
            state = .loading
        }

        do {
            let result = try await placesService.refreshPlacesWithFallback()
            guard !Task.isCancelled else { return }
            let places = result as? [Place] ?? []

            await loadArealImage()
            guard !Task.isCancelled else { return }
            let isStale = (try? await placesService.isDataStale(maxAgeMs: 3600000))?.boolValue ?? true
            guard !Task.isCancelled else { return }
            state = .loaded(places, isStale: isStale)
        } catch {
            guard !Task.isCancelled else { return }
            if case .refreshing(let places) = state {
                state = .loaded(places, isStale: true)
            } else {
                state = .error(error)
            }
        }
    }

    private func refreshAndHandleResult(isRefresh: Bool) async {
        do {
            let result = try await placesService.refreshPlacesWithFallback()
            guard !Task.isCancelled else { return }
            let places = result as? [Place] ?? []

            await loadArealImage()

            guard !Task.isCancelled else { return }
            let isStale = (try? await placesService.isDataStale(maxAgeMs: 3600000))?.boolValue ?? true
            guard !Task.isCancelled else { return }
            state = .loaded(places, isStale: isStale)
        } catch {
            guard !Task.isCancelled else { return }
            if isRefresh, case .refreshing(let places) = state {
                state = .loaded(places, isStale: true)
            } else {
                state = .error(error)
            }
        }
    }

    private func loadArealImage() async {
        do {
            let result = try await placesService.getArealImageURL()
            guard !Task.isCancelled else { return }
            if let arealUrl = result as? String {
                arealImageURL = arealUrl
            }
        } catch {
            print("Failed to load areal image: \(error.localizedDescription)")
        }
    }
}
