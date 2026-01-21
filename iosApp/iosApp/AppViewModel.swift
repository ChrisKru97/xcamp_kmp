import SwiftUI
import shared
import OSLog

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "AppViewModel")

    // Cached services - lazy initialization without nil-checks on each access
    // Note: remoteConfigService must be declared before services that depend on it
    private lazy var remoteConfigService = RemoteConfigService()
    private lazy var appConfigService: AppConfigService = AppConfigService(remoteConfigService: remoteConfigService)
    private lazy var linksService: LinksService = LinksService(remoteConfigService: remoteConfigService)
    private lazy var placesService = PlacesService()
    private lazy var speakersService = SpeakersService()
    private lazy var scheduleService = ScheduleService()

    func initializeApp() {
        logger.debug("initializeApp() - Starting app initialization")

        let authService = AuthService()
        let appConfigService = getAppConfigService()
        logger.debug("initializeApp() - Created AuthService and AppConfigService")

        let appInitializer = AppInitializer(
            appConfigService: appConfigService,
            authService: authService
        )
        logger.debug("initializeApp() - Created AppInitializer")

        Task {
            logger.debug("initializeApp() - Calling appInitializer.initialize()...")
            do {
                try await appInitializer.initialize()
                logger.info("initializeApp() - AppInitializer completed successfully")

                await MainActor.run {
                    self.appState = appConfigService.getAppState()
                    self.logger.info("initializeApp() - Got app state: \(self.appState)")
                    self.isLoading = false
                    self.logger.debug("initializeApp() - Set isLoading = false, main initialization complete")
                }
                // Lazy load places in background after Remote Config loads
                logger.debug("initializeApp() - Starting background sync for places")
                syncPlacesInBackground()
                // Lazy load speakers in background after Remote Config loads
                logger.debug("initializeApp() - Starting background sync for speakers")
                syncSpeakersInBackground()
                // Lazy load schedule in background after Remote Config loads
                logger.debug("initializeApp() - Starting background sync for schedule")
                syncScheduleInBackground()
            } catch {
                logger.error("initializeApp() - AppInitializer failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    /// Syncs places data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncPlacesInBackground() {
        logger.debug("syncPlacesInBackground() - Starting places sync in background")
        Task(priority: .background) { [weak self] in
            guard let self = self else {
                print("AppViewModel.syncPlacesInBackground() - self was nil")
                return
            }
            print("AppViewModel.syncPlacesInBackground() - Task started, getting PlacesService")
            let placesService = await self.getPlacesService()
            do {
                print("AppViewModel.syncPlacesInBackground() - Calling refreshPlaces()...")
                let result = try await placesService.refreshPlaces()
                print("AppViewModel.syncPlacesInBackground() - Successfully refreshed places, got \(result ?? 0) items")
            } catch {
                print("AppViewModel.syncPlacesInBackground() - Failed to refresh places: \(error.localizedDescription)")
            }
        }
    }

    /// Syncs speakers data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncSpeakersInBackground() {
        logger.debug("syncSpeakersInBackground() - Starting speakers sync in background")
        Task(priority: .background) { [weak self] in
            guard let self = self else {
                print("AppViewModel.syncSpeakersInBackground() - self was nil")
                return
            }
            print("AppViewModel.syncSpeakersInBackground() - Task started, getting SpeakersService")
            let speakersService = await self.getSpeakersService()
            do {
                print("AppViewModel.syncSpeakersInBackground() - Calling refreshSpeakers()...")
                let result = try await speakersService.refreshSpeakers()
                print("AppViewModel.syncSpeakersInBackground() - Successfully refreshed speakers, got \(result ?? 0) items")
            } catch {
                print("AppViewModel.syncSpeakersInBackground() - Failed to refresh speakers: \(error.localizedDescription)")
            }
        }
    }

    /// Syncs schedule data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncScheduleInBackground() {
        logger.debug("syncScheduleInBackground() - Starting schedule sync in background")
        Task(priority: .background) { [weak self] in
            guard let self = self else {
                print("AppViewModel.syncScheduleInBackground() - self was nil")
                return
            }
            print("AppViewModel.syncScheduleInBackground() - Task started, getting ScheduleService")
            let scheduleService = await self.getScheduleService()
            do {
                print("AppViewModel.syncScheduleInBackground() - Calling refreshSections()...")
                let result = try await scheduleService.refreshSections()
                print("AppViewModel.syncScheduleInBackground() - Successfully refreshed schedule, got \(result ?? 0) items")
            } catch {
                print("AppViewModel.syncScheduleInBackground() - Failed to refresh schedule: \(error.localizedDescription)")
            }
        }
    }

    // Cached service accessors - no nil-checks needed due to lazy initialization

    func getAppConfigService() -> AppConfigService {
        appConfigService
    }

    func getRemoteConfigService() -> RemoteConfigService {
        remoteConfigService
    }

    func getLinksService() -> LinksService {
        linksService
    }

    func getPlacesService() -> PlacesService {
        placesService
    }

    func getSpeakersService() -> SpeakersService {
        speakersService
    }

    func getScheduleService() -> ScheduleService {
        scheduleService
    }

    /// Get available tabs based on the current app state that was set during initialization
    func getAvailableTabsForCurrentState() -> [AppTab] {
        logger.debug("getAvailableTabsForCurrentState() - Current app state: \(self.appState)")
        let result = getAppConfigService().getAvailableTabs()
        logger.debug("getAvailableTabsForCurrentState() - Got \(result.count) tabs")
        return result
    }
}
