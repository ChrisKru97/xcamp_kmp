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
        AnalyticsHelper.shared.logEvent(name: "screen_view", parameters: [
            "screen_name": "speakers",
            "tab_name": "speakers"
        ])
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
}
