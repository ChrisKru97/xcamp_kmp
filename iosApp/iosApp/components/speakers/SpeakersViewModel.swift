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

    func clearError() {
        lastError = nil
    }

    func loadSpeakers(service: SpeakersService) async {
        state = .loading
        do {
            let speakers = try await service.getAllSpeakers()
            state = .loaded(speakers)
            lastError = nil
        } catch {
            state = .error
            lastError = error
        }
    }

    func refreshSpeakers(service: SpeakersService) async {
        KingfisherManager.shared.cache.clearMemoryCache()
        do {
            _ = try await service.refreshSpeakers()
            await loadSpeakers(service: service)
        } catch {
            lastError = error
        }
    }
}
