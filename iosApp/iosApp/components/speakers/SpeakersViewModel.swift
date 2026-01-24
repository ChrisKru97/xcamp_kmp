import SwiftUI
import shared

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
            // Data is already sorted by SQL: ORDER BY priority, name
            state = .loaded(speakers)
            lastError = nil
        } catch {
            state = .error
            lastError = error
        }
    }

    func refreshSpeakers(service: SpeakersService) async {
        do {
            _ = try await service.refreshSpeakers()
            // On success, reload the speakers from local cache
            await loadSpeakers(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
            lastError = error
        }
    }
}
