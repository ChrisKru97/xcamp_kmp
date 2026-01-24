import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true

    // Cached services - lazy initialization without nil-checks on each access
    // Note: remoteConfigService must be declared before services that depend on it
    private lazy var remoteConfigService = RemoteConfigService()
    private lazy var appConfigService: AppConfigService = AppConfigService(remoteConfigService: remoteConfigService)
    private lazy var linksService: LinksService = LinksService(remoteConfigService: remoteConfigService)
    private lazy var placesService = PlacesService()
    private lazy var speakersService = SpeakersService()
    private lazy var scheduleService = ScheduleService()

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
                    self.appState = appConfigService.getAppState()
                    self.isLoading = false
                }
                // Lazy load places, speakers, and schedule in parallel after Remote Config loads
                await syncAllDataInBackground()
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    /// Syncs all data (places, speakers, schedule) in parallel using async-let
    /// This is more efficient than launching separate tasks as async-let provides
    /// structured concurrency with proper cancellation and error handling
    private func syncAllDataInBackground() async {
        // Run all sync tasks in parallel
        async let places = syncPlaces()
        async let speakers = syncSpeakers()
        async let schedule = syncSchedule()

        // Wait for all tasks to complete
        await (places, speakers, schedule)
    }

    private func syncPlaces() async {
        let placesService = self.getPlacesService()
        try? await placesService.refreshPlaces() as? [Place] ?? []
    }

    private func syncSpeakers() async {
        let speakersService = self.getSpeakersService()
        try? await speakersService.refreshSpeakers() as? [Speaker] ?? []
    }

    private func syncSchedule() async {
        let scheduleService = self.getScheduleService()
        try? await scheduleService.refreshSections() as? [shared.Section] ?? []
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
        getAppConfigService().getAvailableTabs()
    }
}
