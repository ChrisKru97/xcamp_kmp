import SwiftUI
import shared
import Kingfisher

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[Speaker]> = .loading

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    func loadSpeakers() async {
        state = .loading
        logContentState(state: "loading", error: nil)
        do {
            let speakers = try await speakersService.getAllSpeakers()
            guard !Task.isCancelled else { return }
            state = .loaded(speakers)
            logContentState(state: "content", error: nil)

            logScreenView()
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
            logContentState(state: "error", error: error)
        }
    }

    private func logScreenView() {
        Analytics.shared.logScreenView(screenName: "speakers")
    }

    private func logContentState(state: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "speakers",
            AnalyticsEvents.shared.PARAM_STATE: state
        ]
        if let error = error {
            params[AnalyticsEvents.shared.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_STATE, parameters: params)
    }

    func refreshSpeakers() async {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.PULL_REFRESH, parameters: [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "speakers"
        ])

        KingfisherManager.shared.cache.clearMemoryCache()

        switch state {
        case .loaded(let speakers, _):
            state = .refreshing(speakers)
        default:
            state = .loading
        }

        do {
            _ = try await speakersService.refreshSpeakersWithFallback()
            await loadSpeakers()
        } catch {
            guard !Task.isCancelled else { return }
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
