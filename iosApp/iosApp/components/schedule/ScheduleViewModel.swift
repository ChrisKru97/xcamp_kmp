import SwiftUI
import shared

enum ScheduleState {
    case loading
    case loaded([shared.ExpandedSection])
    case error(String)
}

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published private(set) var state: ScheduleState = .loading
    @Published private(set) var selectedDayIndex: Int = 0
    @Published var visibleTypes: Set<SectionType> = Set(SectionType.entries)
    @Published var favoritesOnly: Bool = false
    @Published private(set) var lastError: Error?

    private var remoteConfigService: RemoteConfigService?
    private var userHasSelectedDay: Bool = false

    func setRemoteConfigService(_ service: RemoteConfigService) {
        self.remoteConfigService = service
    }

    private var eventDays: [Int] {
        guard let remoteConfigService else { return [] }
        return Array(AppConfigService(remoteConfigService: remoteConfigService).getEventDays())
    }

    func clearError() {
        lastError = nil
    }

    var filteredSections: [shared.ExpandedSection] {
        guard case .loaded(let sections) = state else {
            return []
        }

        return sections.filter { section in
            guard section.day == Int32(eventDays[selectedDayIndex]) else {
                return false
            }

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
            let startDate = remoteConfigService?.getStartDate() ?? SharedAppConfigServiceKt.DEFAULT_START_DATE
            let sections = try await service.getAllExpandedSections(startDate: startDate)
            state = .loaded(sections)

            // Auto-select current day only if user hasn't manually selected one
            if !userHasSelectedDay {
                selectCurrentDay(sections: sections)
            }
        } catch {
            state = .error(error.localizedDescription)
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
            try await service.toggleFavorite(sectionUid: section.uid, favorite: !section.favorite)
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
        userHasSelectedDay = true
    }

    func loadDay(service: ScheduleService, dayIndex: Int) async {
        guard dayIndex >= 0 && dayIndex < eventDays.count else { return }
        let dayNumber = eventDays[dayIndex]
        let startDate = remoteConfigService?.getStartDate() ?? SharedAppConfigServiceKt.DEFAULT_START_DATE

        do {
            let sections = try await service.getExpandedSections(dayNumber: Int32(dayNumber), startDate: startDate)
            state = .loaded(sections)
        } catch {
            state = .error(error.localizedDescription)
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
}
