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
        Analytics().logScreenView(screenName: "speakers")
    }

    private func logContentState(state: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsParameters.PARAM_SCREEN_NAME: "speakers",
            AnalyticsParameters.PARAM_STATE: state
        ]
        if let error = error {
            params[AnalyticsParameters.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics().logEvent(name: AnalyticsEvents.CONTENT_STATE, parameters: params)
    }

    func refreshSpeakers() async {
        Analytics().logEvent(name: AnalyticsEvents.PULL_REFRESH, parameters: [
            AnalyticsParameters.PARAM_SCREEN_NAME: "speakers"
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
        Analytics().logEvent(name: AnalyticsEvents.CONTENT_VIEW, parameters: [
            AnalyticsParameters.PARAM_CONTENT_TYPE: "speaker",
            AnalyticsParameters.PARAM_CONTENT_ID: speakerId,
            AnalyticsParameters.PARAM_ENTITY_NAME: speakerName
        ])
    }
}
