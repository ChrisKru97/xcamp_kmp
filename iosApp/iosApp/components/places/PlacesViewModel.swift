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
            logContentState(state: "loading", error: nil)
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
        Analytics().logScreenView(screenName: "places")
    }

    private func logContentState(state: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsParameters.PARAM_SCREEN_NAME: "places",
            AnalyticsParameters.PARAM_STATE: state
        ]
        if let error = error {
            params[AnalyticsParameters.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics().logEvent(name: AnalyticsEvents.CONTENT_STATE, parameters: params)
    }

    func refreshPlaces() async {
        Analytics().logEvent(name: AnalyticsEvents.PULL_REFRESH, parameters: [
            AnalyticsParameters.PARAM_SCREEN_NAME: "places"
        ])

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
                logContentState(state: "error", error: error)
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
            logContentState(state: "content", error: nil)
        } catch {
            guard !Task.isCancelled else { return }
            if isRefresh, case .refreshing(let places) = state {
                state = .loaded(places, isStale: true)
            } else {
                state = .error(error)
                logContentState(state: "error", error: error)
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

    func logMapView() {
        Analytics().logEvent(name: AnalyticsEvents.MAP_VIEW, parameters: [
            AnalyticsParameters.PARAM_VIEW_TYPE: "area_map"
        ])
    }

    func logPlaceDetailView(placeId: String, placeName: String) {
        Analytics().logEvent(name: AnalyticsEvents.CONTENT_VIEW, parameters: [
            AnalyticsParameters.PARAM_CONTENT_TYPE: "place",
            AnalyticsParameters.PARAM_CONTENT_ID: placeId,
            AnalyticsParameters.PARAM_ENTITY_NAME: placeName
        ])
    }
}
