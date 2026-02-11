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
    @Published var filterState: ScheduleFilterState = ScheduleFilterState(
        visibleTypes: Set(SectionType.entries),
        favoritesOnly: false
    )
    @Published private(set) var lastError: Error?

    var scheduleService: ScheduleService { ServiceFactory.shared.getScheduleService() }
    var remoteConfigService: RemoteConfigService { ServiceFactory.shared.getRemoteConfigService() }
    var notificationService: NotificationService { ServiceFactory.shared.getNotificationService() }
    private var userHasSelectedDay: Bool = false

    private var eventDays: [Int] {
        Array(AppConfigService(remoteConfigService: remoteConfigService).getEventDays())
            .map { $0.intValue }
    }

    func clearError() {
        lastError = nil
    }

    var filteredSections: [shared.ExpandedSection] {
        guard case .loaded(let sections) = state else {
            return []
        }

        return ScheduleFilter.shared.filterSections(
            sections: sections,
            selectedDay: Int32(eventDays[selectedDayIndex]),
            filterState: filterState
        )
    }

    func loadSections() async {
        state = .loading
        do {
            let startDate = remoteConfigService.getStartDate()
            let sections = try await scheduleService.getAllExpandedSections(startDate: startDate)
            guard !Task.isCancelled else { return }
            state = .loaded(sections)

            if !userHasSelectedDay {
                selectCurrentDay(sections: sections)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }

    func refreshSections() async {
        do {
            _ = try await scheduleService.refreshSections()
            await loadSections()
            lastError = nil
        } catch {
            guard !Task.isCancelled else { return }
            lastError = error
        }
    }

    func toggleFavorite(section: shared.ExpandedSection) async {
        do {
            try await scheduleService.toggleFavorite(sectionUid: section.uid, favorite: !section.favorite)
            guard !Task.isCancelled else { return }
            await loadSections()
            await refreshNotificationsIfNeeded()
            lastError = nil
        } catch {
            guard !Task.isCancelled else { return }
            lastError = error
        }
    }

    func toggleFavorite(sectionUid: String, favorite: Bool) async throws {
        try await scheduleService.toggleFavorite(sectionUid: sectionUid, favorite: favorite)
        await refreshNotificationsIfNeeded()
    }

    private func refreshNotificationsIfNeeded() async {
        let preferences = notificationService.getPreferences()
        guard preferences.scheduleMode == .favorites else { return }

        do {
            try await notificationService.refreshScheduleNotifications()
        } catch {
            print("Failed to refresh notifications: \(error.localizedDescription)")
        }
    }

    func selectDay(index: Int) {
        selectedDayIndex = index
        userHasSelectedDay = true
    }

    func loadDay(dayIndex: Int) async {
        guard dayIndex >= 0 && dayIndex < eventDays.count else { return }
        let dayNumber = eventDays[dayIndex]
        let startDate = remoteConfigService.getStartDate()

        do {
            let sections = try await scheduleService.getExpandedSections(dayNumber: Int32(dayNumber), startDate: startDate)
            guard !Task.isCancelled else { return }
            state = .loaded(sections)
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }

    private func selectCurrentDay(sections: [shared.ExpandedSection]) {
        let now = Date()
        let currentMillis = Int64(now.timeIntervalSince1970 * 1000)

        for section in sections {
            if section.startTime.epochMillis <= currentMillis &&
               section.endTime.epochMillis >= currentMillis {
                if let dayIndex = eventDays.firstIndex(of: Int(section.day)) {
                    selectedDayIndex = dayIndex
                    return
                }
            }
        }

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
