import SwiftUI
import shared

enum ScheduleState {
    case loading
    case loaded([shared.ExpandedSection])
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
    @Published private(set) var lastError: Error?

    private var remoteConfigService: RemoteConfigService?

    private var eventDays: [Int] {
        guard let remoteConfigService,
              let startDate = parseStartDate(remoteConfigService.getStartDate()) else {
            return [18, 19, 20, 21, 22, 23, 24, 25]
        }

        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: startDate)
        return (0..<8).map { startDay + $0 }
    }

    func setRemoteConfigService(_ service: RemoteConfigService) {
        self.remoteConfigService = service
    }

    func clearError() {
        lastError = nil
    }

    var filteredSections: [shared.ExpandedSection] {
        guard case .loaded(let sections) = state else {
            return []
        }

        return sections.filter { section in
            guard visibleTypes.contains(section.type) else {
                return false
            }

            if favoritesOnly && !section.favorite {
                return false
            }

            return true
        }
    }

    func loadSections(service: ScheduleService) async {
        state = .loading
        do {
            let startDate = remoteConfigService?.getStartDate() ?? "2026-07-18"
            let sections = try await service.getAllExpandedSections(startDate: startDate)
            state = .loaded(sections)

            // Auto-select current day if applicable
            selectCurrentDay(sections: sections)
        } catch {
            state = .error
        }
    }

    func refreshSections(service: ScheduleService) async {
        do {
            _ = try await service.refreshSections()
            // On success, reload the sections from local cache
            await loadSections(service: service)
            lastError = nil
        } catch {
            // If refresh fails, keep showing existing data but track the error
            lastError = error
        }
    }

    func toggleFavorite(section: shared.ExpandedSection, service: ScheduleService) async {
        do {
            try await service.toggleFavorite(sectionId: section.id, favorite: !section.favorite)
            await loadSections(service: service)
            lastError = nil
        } catch {
            lastError = error
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

    func loadDay(service: ScheduleService, dayIndex: Int) async {
        guard dayIndex >= 0 && dayIndex < eventDays.count else { return }
        let dayNumber = eventDays[dayIndex]
        let startDate = remoteConfigService?.getStartDate() ?? "2026-07-18"

        do {
            let sections = try await service.getExpandedSections(dayNumber: Int32(dayNumber), startDate: startDate)
            state = .loaded(sections)
        } catch {
            state = .error
        }
    }

    private func selectCurrentDay(sections: [shared.ExpandedSection]) {
        let now = Date()
        let currentMillis = Int64(now.timeIntervalSince1970 * 1000)

        // Find first section that is currently happening
        for section in sections {
            if section.startTime.epochMillis <= currentMillis &&
               section.endTime.epochMillis >= currentMillis {
                // Find day index from section's day number
                if let dayIndex = eventDays.firstIndex(of: Int(section.day)) {
                    selectedDayIndex = dayIndex
                    return
                }
            }
        }

        // If no current section, find the next upcoming one
        for section in sections {
            if section.startTime.epochMillis > currentMillis {
                if let dayIndex = eventDays.firstIndex(of: Int(section.day)) {
                    selectedDayIndex = dayIndex
                    return
                }
            }
        }
    }

    private func parseStartDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
}
