import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    private var appConfigService: AppConfigService?
    private var remoteConfigService: RemoteConfigService?
    private var linksService: LinksService?
    private var placesService: PlacesService?
    private var speakersService: SpeakersService?
    private var scheduleService: ScheduleService?

    func initializeApp() {
        let authService = AuthService()
        let appConfigService = getAppConfigService()

        let appInitializer = AppInitializer(
            appConfigService: appConfigService,
            authService: authService
        )

        Task {
            do {
                try await appInitializer.initialize()
                await MainActor.run {
                    appState = appConfigService.getAppState()
                    isLoading = false
                }
                // Lazy load places in background after Remote Config loads
                syncPlacesInBackground()
                // Lazy load speakers in background after Remote Config loads
                syncSpeakersInBackground()
                // Lazy load schedule in background after Remote Config loads
                syncScheduleInBackground()
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    /// Syncs places data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncPlacesInBackground() {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            let placesService = await self.getPlacesService()
            do {
                _ = try await placesService.refreshPlaces()
            } catch {
                // Silently handle errors - background sync is optional
            }
        }
    }

    /// Syncs speakers data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncSpeakersInBackground() {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            let speakersService = await self.getSpeakersService()
            do {
                _ = try await speakersService.refreshSpeakers()
            } catch {
                // Silently handle errors - background sync is optional
            }
        }
    }

    /// Syncs schedule data in the background after app initialization
    /// Uses Task.detached to avoid blocking the main initialization flow
    private func syncScheduleInBackground() {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            let scheduleService = await self.getScheduleService()
            do {
                _ = try await scheduleService.refreshSections()
            } catch {
                // Silently handle errors - background sync is optional
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
