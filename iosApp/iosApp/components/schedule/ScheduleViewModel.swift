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
        logContentState(state: "loading", error: nil)
        do {
            let startDate = remoteConfigService.getStartDate()
            let sections = try await scheduleService.getAllExpandedSections(startDate: startDate)
            guard !Task.isCancelled else { return }
            state = .loaded(sections)
            logContentState(state: "content", error: nil)

            if !userHasSelectedDay {
                selectCurrentDay(sections: sections)
            }

            logScreenView()
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
            logContentState(state: "error", error: error)
        }
    }

    private func logScreenView() {
        Analytics.shared.logScreenView(screenName: "schedule")
    }

    private func logContentState(state: String, error: Error?) {
        var params: [String: String] = [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "schedule",
            AnalyticsEvents.shared.PARAM_STATE: state
        ]
        if let error = error {
            params[AnalyticsEvents.shared.PARAM_ERROR_TYPE] = error.localizedDescription
        }
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_STATE, parameters: params)
    }

    func refreshSections() async {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.PULL_REFRESH, parameters: [
            AnalyticsEvents.shared.PARAM_SCREEN_NAME: "schedule"
        ])

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

            let eventName = isAdding ? AnalyticsEvents.shared.FAVORITE_ADD : AnalyticsEvents.shared.FAVORITE_REMOVE
            Analytics.shared.logEvent(name: eventName, parameters: [
                AnalyticsEvents.shared.PARAM_ENTITY_TYPE: "session",
                AnalyticsEvents.shared.PARAM_ENTITY_ID: section.uid,
                AnalyticsEvents.shared.PARAM_ENTITY_NAME: section.name
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
        let dayName = "Day \(dayNumber)"
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.DAY_SELECT, parameters: [
            AnalyticsEvents.shared.PARAM_DAY_NUMBER: String(dayNumber),
            AnalyticsEvents.shared.PARAM_DAY_NAME: dayName
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

    func logContentView(sectionId: String, sectionName: String) {
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.CONTENT_VIEW, parameters: [
            AnalyticsEvents.shared.PARAM_CONTENT_TYPE: "session",
            AnalyticsEvents.shared.PARAM_CONTENT_ID: sectionId
        ])
    }
}
