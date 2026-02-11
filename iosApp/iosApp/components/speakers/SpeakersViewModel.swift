import SwiftUI
import shared
import Kingfisher

enum SpeakersState {
    case loading
    case loaded([Speaker])
    case error
}

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: SpeakersState = .loading
    @Published private(set) var lastError: Error?
    @Published private(set) var isRefreshing = false

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
            state = .error
            lastError = error
        }
    }

    func refreshSpeakers() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer {
            isRefreshing = false
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
