import SwiftUI
import shared
import Kingfisher

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[Speaker]> = .loading
    @Published private(set) var lastError: Error?

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    func loadSpeakers() async {
        state = .loading
        do {
            let speakers = try await speakersService.getAllSpeakers()
            guard !Task.isCancelled else { return }
            state = .loaded(speakers)
            lastError = nil
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
            lastError = error
        }
    }

    func refreshSpeakers() async {
        switch state {
        case .loaded(let speakers, _):
            state = .refreshing(speakers)
        default:
            state = .loading
        }

        KingfisherManager.shared.cache.clearMemoryCache()
        do {
            _ = try await speakersService.refreshSpeakers()
            await loadSpeakers()
        } catch {
            guard !Task.isCancelled else { return }
            lastError = error
        }
    }
}
