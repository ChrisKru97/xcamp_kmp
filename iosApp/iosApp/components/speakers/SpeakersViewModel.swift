import SwiftUI
import shared
import Kingfisher

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[Speaker]> = .loading

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    func loadSpeakers() async {
        state = .loading
        logContentState(stateName: "loading", error: nil)

        let hasCached = try? await speakersService.hasCachedData()

        if hasCached?.boolValue == true {
            do {
                let speakers = try await speakersService.getAllSpeakers()
                guard !Task.isCancelled else { return }
                state = .loaded(speakers, isStale: false)
                logContentState(stateName: "content", error: nil)

                logScreenView()
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(error)
                logContentState(stateName: "error", error: error)
            }
        } else {
            await refreshAndHandleResult(isRefresh: false)
        }
    }

    private func logScreenView() {
        Analytics.shared.logScreenView(screenName: "speakers")
    }

    private func logContentState(stateName: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "speakers",
            AnalyticsEvents.shared.PARAM_STATE: stateName
        ]
        if let error = error {
            params[AnalyticsEvents.shared.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_STATE, parameters: params)
    }

    private func refreshAndHandleResult(isRefresh: Bool) async {
        do {
            _ = try await speakersService.refreshSpeakersWithFallback()
            guard !Task.isCancelled else { return }
            let speakers = try await speakersService.getAllSpeakers()
            guard !Task.isCancelled else { return }
            state = .loaded(speakers, isStale: false)
            logContentState(stateName: "content", error: nil)

            logScreenView()
        } catch {
            guard !Task.isCancelled else { return }
            if isRefresh, case .refreshing(let speakers) = state {
                state = .loaded(speakers, isStale: true)
            } else {
                state = .error(error)
                logContentState(stateName: "error", error: error)
            }
        }
    }

    func refreshSpeakers() async {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.PULL_REFRESH, parameters: [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "speakers"
        ])

        KingfisherManager.shared.cache.clearMemoryCache()

        switch state {
        case .loaded(let speakers, _):
            state = .refreshing(speakers)
        case .error:
            state = .loading
        case .loading, .refreshing:
            break
        }

        do {
            _ = try await speakersService.refreshSpeakersWithFallback()
            await loadSpeakers()
        } catch {
            guard !Task.isCancelled else { return }
            if case .refreshing(let speakers) = state {
                state = .loaded(speakers, isStale: true)
            }
        }
    }

    func logSpeakerDetailView(speakerId: String, speakerName: String) {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_VIEW, parameters: [
            AnalyticsEvents.shared.PARAM_CONTENT_TYPE: "speaker",
            AnalyticsEvents.shared.PARAM_CONTENT_ID: speakerId,
            AnalyticsEvents.shared.PARAM_ENTITY_NAME: speakerName
        ])
    }
}
