import SwiftUI
import shared
import Kingfisher

let staleDataMaxAgeMs: Int64 = 3600000

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
        let isStale = try? await placesService.isDataStale(maxAgeMs: staleDataMaxAgeMs).boolValue

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
        Analytics.shared.logScreenView(screenName: "places")
    }

    private func logContentState(state: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "places",
            AnalyticsEvents.shared.PARAM_STATE: state
        ]
        if let error = error {
            params[AnalyticsEvents.shared.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_STATE, parameters: params)
    }

    func refreshPlaces() async {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.PULL_REFRESH, parameters: [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "places"
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
            let isStale = (try? await placesService.isDataStale(maxAgeMs: staleDataMaxAgeMs))?.boolValue ?? true
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
            let isStale = (try? await placesService.isDataStale(maxAgeMs: staleDataMaxAgeMs))?.boolValue ?? true
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
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.MAP_VIEW, parameters: [
            AnalyticsEvents.shared.PARAM_VIEW_TYPE: "area_map"
        ])
    }

    func logPlaceDetailView(placeId: String, placeName: String) {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_VIEW, parameters: [
            AnalyticsEvents.shared.PARAM_CONTENT_TYPE: "place",
            AnalyticsEvents.shared.PARAM_CONTENT_ID: placeId,
            AnalyticsEvents.shared.PARAM_ENTITY_NAME: placeName
        ])
    }
}
