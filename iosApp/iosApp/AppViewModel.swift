import SwiftUI
import shared
import OSLog
import os.signpost

// MARK: - App Initialization Signposts

private extension OSLog {
    /// Signpost log for app initialization performance instrumentation
    static let appInit = OSLog(subsystem: "com.krutsche.xcamp", category: "AppInitialization")
}

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
        let signpostID = OSSignpostID(log: OSLog.appInit)
        os_signpost(.begin, log: OSLog.appInit, name: "InitializeApp", signpostID: signpostID)

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
            os_signpost(.begin, log: OSLog.appInit, name: "AppInitializerInit", signpostID: signpostID)
            logger.debug("initializeApp() - Calling appInitializer.initialize()...")
            do {
                try await appInitializer.initialize()
                os_signpost(.end, log: OSLog.appInit, name: "AppInitializerInit", signpostID: signpostID)
                logger.info("initializeApp() - AppInitializer completed successfully")

                await MainActor.run {
                    self.appState = appConfigService.getAppState()
                    self.logger.info("initializeApp() - Got app state: \(self.appState)")
                    self.isLoading = false
                    self.logger.debug("initializeApp() - Set isLoading = false, main initialization complete")
                    os_signpost(.event, log: OSLog.appInit, name: "FirstInteractiveFrame", signpostID: signpostID)
                }
                // Lazy load places, speakers, and schedule in parallel after Remote Config loads
                logger.debug("initializeApp() - Starting parallel background sync")
                os_signpost(.begin, log: OSLog.appInit, name: "BackgroundSync", signpostID: signpostID)
                await syncAllDataInBackground()
                os_signpost(.end, log: OSLog.appInit, name: "BackgroundSync", signpostID: signpostID)
                os_signpost(.end, log: OSLog.appInit, name: "InitializeApp", signpostID: signpostID)
            } catch {
                os_signpost(.end, log: OSLog.appInit, name: "AppInitializerInit", signpostID: signpostID)
                logger.error("initializeApp() - AppInitializer failed: \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    /// Syncs all data (places, speakers, schedule) in parallel using TaskGroup
    /// This is more efficient than launching separate tasks as TaskGroup provides
    /// structured concurrency with proper cancellation and error handling
    private func syncAllDataInBackground() async {
        logger.debug("syncAllDataInBackground() - Starting parallel sync with TaskGroup")

        await withTaskGroup(of: Void.self) { group in
            // Add places sync task
            group.addTask(priority: .background) {
                self.logger.debug("syncAllDataInBackground() - Places sync task started")
                let placesService = self.getPlacesService()
                do {
                    let result = try await placesService.refreshPlaces()
                    self.logger.info("syncAllDataInBackground() - Places sync completed: \(result ?? 0) items")
                } catch {
                    self.logger.error("syncAllDataInBackground() - Places sync failed: \(error.localizedDescription)")
                }
            }

            // Add speakers sync task
            group.addTask(priority: .background) {
                self.logger.debug("syncAllDataInBackground() - Speakers sync task started")
                let speakersService = self.getSpeakersService()
                do {
                    let result = try await speakersService.refreshSpeakers()
                    self.logger.info("syncAllDataInBackground() - Speakers sync completed: \(result ?? 0) items")
                } catch {
                    self.logger.error("syncAllDataInBackground() - Speakers sync failed: \(error.localizedDescription)")
                }
            }

            // Add schedule sync task
            group.addTask(priority: .background) {
                self.logger.debug("syncAllDataInBackground() - Schedule sync task started")
                let scheduleService = self.getScheduleService()
                do {
                    let result = try await scheduleService.refreshSections()
                    self.logger.info("syncAllDataInBackground() - Schedule sync completed: \(result ?? 0) items")
                } catch {
                    self.logger.error("syncAllDataInBackground() - Schedule sync failed: \(error.localizedDescription)")
                }
            }
        }

        logger.info("syncAllDataInBackground() - All parallel sync tasks completed")
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
