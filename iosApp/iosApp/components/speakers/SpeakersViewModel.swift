import SwiftUI
import shared
import Kingfisher

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[Speaker]> = .loading

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    func loadSpeakers() async {
        state = .loading
        do {
            let speakers = try await speakersService.getAllSpeakers()
            guard !Task.isCancelled else { return }
            state = .loaded(speakers)

            logScreenView()
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }

    private func logScreenView() {
        Analytics.Companion.logScreenView(screenName: "speakers")
    }

    func refreshSpeakers() async {
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
        Analytics.Companion.logEvent(name: AnalyticsEventsKt.CONTENT_VIEW, parameters: [
            AnalyticsEventsKt.PARAM_CONTENT_TYPE: "speaker",
            AnalyticsEventsKt.PARAM_CONTENT_ID: speakerId,
            AnalyticsEventsKt.PARAM_ENTITY_NAME: speakerName
        ])
    }
}
