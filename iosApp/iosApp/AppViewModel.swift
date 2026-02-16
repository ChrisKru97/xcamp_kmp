import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    @Published var showForceUpdateAlert: Bool = false
    @Published var showForceUpdateWarning: Bool = false

    private let initializationCanceller = TaskCanceller()
    private let foregroundCanceller = TaskCanceller()

    // ServiceFactory-backed services - singletons managed by shared module
    var remoteConfigService: RemoteConfigService { ServiceFactory.shared.getRemoteConfigService() }
    var appConfigService: AppConfigService { ServiceFactory.shared.getAppConfigService() }
    var linksService: LinksService { ServiceFactory.shared.getLinksService() }
    var placesService: PlacesService { ServiceFactory.shared.getPlacesService() }
    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }
    var scheduleService: ScheduleService { ServiceFactory.shared.getScheduleService() }
    var notificationService: NotificationService { ServiceFactory.shared.getNotificationService() }

    deinit {
        initializationCanceller.cancel()
        foregroundCanceller.cancel()
    }

    func logTabSwitch(from: AppTab, to: AppTab) {
        let currentTabName = tabName(for: to)
        let previousTabName = tabName(for: from)
        Analytics.shared.logEvent(name: AnalyticsEvents.shared.TAB_SWITCH, parameters: [
            AnalyticsEvents.shared.PARAM_TAB_NAME: currentTabName,
            AnalyticsEvents.shared.PARAM_PREVIOUS_TAB: previousTabName
        ])
    }

    // TODO unify with navigationcontainer
    private func tabName(for tab: AppTab) -> String {
        switch tab {
        case .home: return Strings.Tabs.shared.HOME
        case .schedule: return Strings.Tabs.shared.SCHEDULE
        case .speakersAndPlaces: return Strings.Tabs.shared.SPEAKERS_AND_PLACES
        case .rating: return Strings.Tabs.shared.RATING
        case .media: return Strings.Tabs.shared.MEDIA
        case .aboutFestival: return Strings.Tabs.shared.ABOUT_FESTIVAL
        default: return ""
        }
    }

    func initialize(notificationDelegate: NotificationDelegate) {
        notificationDelegate.registerForRemoteNotifications()

        initializationCanceller.run { [self] in
            let platform = Platform()

            let appInitializer = AppInitializer(
                appConfigService: appConfigService,
                platform: platform
            )

            do {
                try await appInitializer.initialize()
                try await notificationService.initialize()

                guard !Task.isCancelled else { return }

                await checkForceUpdate(currentVersion: platform.appVersion)

                await MainActor.run {
                    self.appState = appConfigService.getAppState()
                    self.isLoading = false
                }
                guard !Task.isCancelled else { return }

                await syncAllDataInBackground()

                await refreshScheduleNotificationsIfNeeded()
                await refreshPrayerNotificationIfNeeded()
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    func checkForceUpdate(currentVersion: String) async {
        let forceUpdateVersion = remoteConfigService.forceUpdateVersion
        let dismissedVersion = AppPreferences.shared.getDismissedForceUpdateVersion()
        if VersionUtilsKt.needsForceUpdate(currentVersion: currentVersion, requiredVersion: forceUpdateVersion),
           dismissedVersion != forceUpdateVersion {
            await MainActor.run {
                showForceUpdateAlert = true
            }
        }
    }

    func checkForceUpdateOnForeground() async {
        foregroundCanceller.run { [self] in
            let platform = Platform()
            _ = try? await remoteConfigService.fetchAndActivate()
            guard !Task.isCancelled else { return }
            await checkForceUpdate(currentVersion: platform.appVersion)
        }
    }

    private func syncAllDataInBackground() async {
        async let places = syncPlaces()
        async let speakers = syncSpeakers()
        async let schedule = syncSchedule()

        await (places, speakers, schedule)
    }

    private func syncPlaces() async {
        do {
            let _ = try await placesService.refreshPlacesWithFallback()
        } catch {
            print("Places sync failed: \(error.localizedDescription)")
        }
    }

    private func syncSpeakers() async {
        do {
            let _ = try await speakersService.refreshSpeakersWithFallback()
        } catch {
            print("Speakers sync failed: \(error.localizedDescription)")
        }
    }

    private func syncSchedule() async {
        do {
            let _ = try await scheduleService.refreshSectionsWithFallback()
        } catch {
            print("Schedule sync failed: \(error.localizedDescription)")
        }
    }

    private func refreshScheduleNotificationsIfNeeded() async {
        guard appState == .activeEvent else { return }

        do {
            try await notificationService.refreshScheduleNotifications()
        } catch {
            print("Failed to refresh notifications: \(error.localizedDescription)")
        }
    }

    private func refreshPrayerNotificationIfNeeded() async {
        let preferences = notificationService.getPreferences()
        guard preferences.prayerDayEnabled else { return }

        guard appState == .limited || appState == .preEvent else {
            try? await notificationService.cancelPrayerNotification()
            return
        }

        let startDate = remoteConfigService.startDate
        try? await notificationService.schedulePrayerNotifications(startDate: startDate)
    }
}
