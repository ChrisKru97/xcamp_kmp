import SwiftUI
import shared

enum ScheduleState {
    case loading
    case loaded([shared.Section])
    case error
}

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published private(set) var state: ScheduleState = .loading
    @Published private(set) var selectedDayIndex: Int = 0
    @Published var visibleTypes: Set<SectionType> = Set([
        .main, .internal, .gospel, .food
    ])
    @Published var favoritesOnly: Bool = false

    private var allSections: [shared.Section] = []

    var filteredSections: [shared.Section] {
        guard case .loaded(let sections) = state else {
            return []
        }

        return sections.filter { section in
            // Filter by type
            guard visibleTypes.contains(section.type) else {
                return false
            }

            // Filter by favorites
            if favoritesOnly && !section.favorite {
                return false
            }

            return true
        }
    }

    func loadSections(service: ScheduleService) async {
        state = .loading
        do {
            let sections = try await service.getAllSections()
            allSections = sections
            // Sort by start time
            let sortedSections = sections.sorted(by: { lhs, rhs in
                return lhs.startTime.epochMillis < rhs.startTime.epochMillis
            })
            state = .loaded(sortedSections)

            // Auto-select current day if applicable
            selectCurrentDay(sections: sortedSections)
        } catch {
            state = .error
        }
    }

    func refreshSections(service: ScheduleService) async {
        do {
            _ = try await service.refreshSections()
            // On success, reload the sections from local cache
            await loadSections(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
        }
    }

    func toggleFavorite(section: shared.Section, service: ScheduleService) async {
        do {
            try await service.toggleFavorite(sectionId: section.id, favorite: !section.favorite)
            // Reload to reflect changes
            await loadSections(service: service)
        } catch {
            // Handle error silently or show error
        }
    }

    func toggleTypeFilter(_ type: SectionType) {
        if visibleTypes.contains(type) {
            visibleTypes.remove(type)
        } else {
            visibleTypes.insert(type)
        }
    }

    func toggleFavoritesOnly() {
        favoritesOnly.toggle()
    }

    func selectDay(index: Int) {
        selectedDayIndex = index
    }

    private func selectCurrentDay(sections: [shared.Section]) {
        let now = Date()
        let currentMillis = Int64(now.timeIntervalSince1970 * 1000)

        // Find first section that is currently happening
        for section in sections {
            if section.startTime.epochMillis <= currentMillis &&
               section.endTime.epochMillis >= currentMillis {
                // Calculate day index from start time
                selectedDayIndex = calculateDayIndex(from: section.startTime.epochMillis)
                return
            }
        }

        // If no current section, find the next upcoming one
        for section in sections {
            if section.startTime.epochMillis > currentMillis {
                selectedDayIndex = calculateDayIndex(from: section.startTime.epochMillis)
                return
            }
        }
    }

    private func calculateDayIndex(from millis: Int64) -> Int {
        // Assuming event starts on a specific date, calculate day index
        // For now, return 0 as default
        // TODO: Implement based on actual event start date from Remote Config
        return 0
    }
}
