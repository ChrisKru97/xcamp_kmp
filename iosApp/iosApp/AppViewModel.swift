import SwiftUI
import shared
import OSLog

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "AppViewModel")
    private var appConfigService: AppConfigService?
    private var remoteConfigService: RemoteConfigService?
    private var linksService: LinksService?
    private var placesService: PlacesService?
    private var speakersService: SpeakersService?
    private var scheduleService: ScheduleService?

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

    func getAppConfigService() -> AppConfigService {
        guard let appConfigService = appConfigService else {
            let newAppConfigService = AppConfigService(remoteConfigService: getRemoteConfigService())
            appConfigService = newAppConfigService
            return newAppConfigService
        }
        return appConfigService
    }

    func getRemoteConfigService() -> RemoteConfigService {
        guard let remoteConfigService = remoteConfigService else {
            let newRemoteConfigService = RemoteConfigService()
            remoteConfigService = newRemoteConfigService
            return newRemoteConfigService
        }
        return remoteConfigService
    }

    func getLinksService() -> LinksService {
        guard let linksService = linksService else {
            let newLinksService = LinksService(
                remoteConfigService: getRemoteConfigService()
            )
            self.linksService = newLinksService
            return newLinksService
        }
        return linksService
    }

    func getPlacesService() -> PlacesService {
        guard let placesService = placesService else {
            let newPlacesService = PlacesService()
            self.placesService = newPlacesService
            return newPlacesService
        }
        return placesService
    }

    func getSpeakersService() -> SpeakersService {
        guard let speakersService = speakersService else {
            let newSpeakersService = SpeakersService()
            self.speakersService = newSpeakersService
            return newSpeakersService
        }
        return speakersService
    }

    func getScheduleService() -> ScheduleService {
        guard let scheduleService = scheduleService else {
            let newScheduleService = ScheduleService()
            self.scheduleService = newScheduleService
            return newScheduleService
        }
        return scheduleService
    }
}
