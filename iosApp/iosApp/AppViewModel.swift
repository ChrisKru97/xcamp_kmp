import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    @Published var showForceUpdateAlert: Bool = false
    @Published var showForceUpdateWarning: Bool = false

    // Cached services - lazy initialization without nil-checks on each access
    // Note: remoteConfigService must be declared before services that depend on it
    lazy var remoteConfigService = RemoteConfigService()
    lazy var appConfigService: AppConfigService = AppConfigService(remoteConfigService: remoteConfigService)
    lazy var linksService: LinksService = LinksService(remoteConfigService: remoteConfigService)
    lazy var placesService = PlacesService()
    lazy var speakersService = SpeakersService()
    lazy var scheduleService = ScheduleService()

    #if targetEnvironment(simulator)
    var isSimulator: Bool { true }
    #else
    var isSimulator: Bool { false }
    #endif

    func initializeApp() {
        let authService = AuthService()

        let appInitializer = AppInitializer(
            appConfigService: appConfigService,
            authService: authService
        )

        Task {
            do {
                try await appInitializer.initialize()
                
                await checkForceUpdate(currentVersion: platform.appVersion)

                await MainActor.run {
                    var calculatedState = appConfigService.getAppState()
                    // Override to ACTIVE_EVENT when running in simulator for development
                    if isSimulator {
                        calculatedState = .activeEvent
                    }
                    self.appState = calculatedState
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

    func checkForceUpdate(currentVersion: String) async {
        let forceUpdateVersion = remoteConfigService.getForceUpdateVersion()
        let dismissedVersion = AppPreferences.getDismissedForceUpdateVersion()
        if VersionUtilsKt.needsForceUpdate(currentVersion: currentVersion, requiredVersion: forceUpdateVersion),
           dismissedVersion != forceUpdateVersion {
            await MainActor.run {
                showForceUpdateAlert = true
            }
        }
    }

    func checkForceUpdateOnForeground() async {
        let platform = Platform()
        _ = try? await remoteConfigService.fetchAndActivate()
        await checkForceUpdate(currentVersion: platform.appVersion)
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
        try? await placesService.refreshPlaces()
    }

    private func syncSpeakers() async {
        try? await speakersService.refreshSpeakers()
    }

    private func syncSchedule() async {
        try? await scheduleService.refreshSections()
    }
}
