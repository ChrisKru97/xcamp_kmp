import SwiftUI
import Kingfisher
import shared

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published private(set) var state: ContentState<[shared.ExpandedSection]> = .loading
    @Published private(set) var selectedDayIndex: Int = 0
    @Published var filterState: ScheduleFilterState = ScheduleFilterState(
        visibleTypes: Set(SectionType.entries),
        favoritesOnly: false
    )

    var scheduleService: ScheduleService { ServiceFactory.shared.getScheduleService() }
    var remoteConfigService: RemoteConfigService { ServiceFactory.shared.getRemoteConfigService() }
    var notificationService: NotificationService { ServiceFactory.shared.getNotificationService() }
    private var userHasSelectedDay: Bool = false

    private var eventDays: [Int] {
        Array(AppConfigService(remoteConfigService: remoteConfigService).getEventDays())
            .map { $0.intValue }
    }

    var filteredSections: [shared.ExpandedSection] {
        let sectionsToFilter: [shared.ExpandedSection]?
        switch state {
        case .loaded(let s, _):
            sectionsToFilter = s
        case .refreshing(let s):
            sectionsToFilter = s
        default:
            return []
        }

        guard let sections = sectionsToFilter else { return [] }

        let selectedDay = Int32(eventDays[selectedDayIndex])

        return ScheduleFilter.shared.filterSectionsByDay(
            sections: sections,
            selectedDay: selectedDay
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

            logScreenView()
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }

    private func logScreenView() {
        AnalyticsHelper.shared.logEvent(name: "screen_view", parameters: [
            "screen_name": "schedule",
            "tab_name": "schedule"
        ])
    }

    func refreshSections() async {
        switch state {
        case .loaded(let sections, _):
            state = .refreshing(sections)
        default:
            state = .loading
        }

        do {
            _ = try await scheduleService.refreshSectionsWithFallback()
            await loadSections()
        } catch {
            guard !Task.isCancelled else { return }
            if case .refreshing(let sections) = state {
                state = .loaded(sections, isStale: true)
            } else {
                state = .error(error)
            }
        }
    }

    func toggleFavorite(section: shared.ExpandedSection) async {
        let isAdding = !section.favorite
        do {
            try await scheduleService.toggleFavorite(sectionUid: section.uid, favorite: isAdding)
            guard !Task.isCancelled else { return }
            await reloadCurrentDayWithFilter()
            await refreshNotificationsIfNeeded()

            let eventName = isAdding ? "favorite_add" : "favorite_remove"
            AnalyticsHelper.shared.logEvent(name: eventName, parameters: [
                "entity_type": "session",
                "entity_id": section.uid,
                "entity_name": section.name
            ])
        } catch {
            guard !Task.isCancelled else { return }
            print("Failed to toggle favorite: \(error.localizedDescription)")
        }
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

        let dayNumber = eventDays[index]
        AnalyticsHelper.shared.logEvent(name: "screen_view", parameters: [
            "screen_name": "schedule_day",
            "day_number": String(dayNumber)
        ])
    }

    func reloadCurrentDayWithFilter() async {
        await loadDay(dayIndex: selectedDayIndex)
    }

    func loadDay(dayIndex: Int) async {
        guard dayIndex >= 0 && dayIndex < eventDays.count else { return }

        switch state {
        case .loaded, .refreshing:
            state = .loading
        default:
            break
        }

        let dayNumber = eventDays[dayIndex]
        let startDate = remoteConfigService.getStartDate()

        do {
            let types = filterState.visibleTypes
            let sections = try await scheduleService.getExpandedSectionsByTypesAndFavorite(
                dayNumber: Int32(dayNumber),
                types: types,
                favoritesOnly: filterState.favoritesOnly,
                startDate: startDate
            )
            guard !Task.isCancelled else { return }
            state = .loaded(sections)
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }

    private func selectCurrentDay(sections: [shared.ExpandedSection]) {
        let now = Date()
        let currentMillis = Int64(now.timeIntervalSince1970 * 1000)

        for section in sections {
            if section.startTime.toEpochMilliseconds() <= currentMillis &&
               section.endTime.toEpochMilliseconds() >= currentMillis {
                if let dayIndex = eventDays.firstIndex(of: Int(section.day)) {
                    selectedDayIndex = dayIndex
                    return
                }
            }
        }

        for section in sections {
            if section.startTime.toEpochMilliseconds() > currentMillis {
                if let dayIndex = eventDays.firstIndex(of: Int(section.day)) {
                    selectedDayIndex = dayIndex
                    return
                }
            }
        }
    }
}
