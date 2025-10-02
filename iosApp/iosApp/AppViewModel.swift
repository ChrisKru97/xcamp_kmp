import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    private var appConfigService: AppConfigService?

    func initializeApp() {
        FirebaseConfig.shared.initialize()

        let driverFactory = DatabaseDriverFactory()
        let _databaseManager = DatabaseManager(driverFactory: driverFactory)
        let authService = AuthService()
        let remoteConfigService = RemoteConfigService()
        appConfigService = AppConfigService(remoteConfigService: remoteConfigService)

        guard let appConfigService = appConfigService else {
            errorMessage = "Failed to initialize app configuration"
            isLoading = false
            return
        }

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
            } catch {
                await MainActor.run {
                    errorMessage = "Initialization failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    func getAppConfigService() -> AppConfigService? {
        return appConfigService
    }
}
