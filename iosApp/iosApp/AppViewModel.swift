import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    private var appConfigService: AppConfigService?

    func initializeApp() {
        let driverFactory = DatabaseDriverFactory()
        let _databaseManager = DatabaseManager(driverFactory: driverFactory)
        let authService = AuthService()
        let remoteConfigService = RemoteConfigService()
        appConfigService = AppConfigService(remoteConfigService: remoteConfigService)
        
        guard let appConfigService = appConfigService else {
            return
        }
        
        let appInitializer = AppInitializer(
            appConfigService: appConfigService,
            authService: authService
        )

        Task {
            // FirebaseConfig.shared.initialize()
            try await appInitializer.initialize()
            appState = appConfigService.getAppState()
        }
    }

    func getAppConfigService() -> AppConfigService? {
        return appConfigService
    }
}
