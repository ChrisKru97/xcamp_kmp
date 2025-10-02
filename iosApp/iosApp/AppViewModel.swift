import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    private var appConfigService: AppConfigService?
    private var remoteConfigService: RemoteConfigService?

    func initializeApp() {
        FirebaseConfig.shared.initialize()

        let driverFactory = DatabaseDriverFactory()
        let _databaseManager = DatabaseManager(driverFactory: driverFactory)
        let authService = AuthService()
        remoteConfigService = RemoteConfigService()

        guard let remoteConfigService = remoteConfigService else {
            errorMessage = "Failed to initialize remote configuration"
            isLoading = false
            return
        }
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

    func getAppConfigService() -> AppConfigService {
        guard let appConfigService = appConfigService else {
            fatalError("AppConfigService not initialized. Call initializeApp() first.")
        }
        return appConfigService
    }

    func getRemoteConfigService() -> RemoteConfigService {
        guard let remoteConfigService = remoteConfigService else {
            fatalError("RemoteConfigService not initialized. Call initializeApp() first.")
        }
        return remoteConfigService
    }
}
