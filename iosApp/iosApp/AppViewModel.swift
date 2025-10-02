import SwiftUI
import shared
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var isInitialized = false
    @Published var appState: AppState = .limited
    @Published var availableTabs: [AppTab] = []
    @Published var startDate: String = "2026-07-18"
    @Published var mainInfo: String = "Welcome to Xcamp!"

    private var xcampApp: XcampApp?
    private var appConfigService: AppConfigService?

    func initializeApp() {
        let driverFactory = DatabaseDriverFactory()
        let databaseManager = DatabaseManager(driverFactory: driverFactory)

        // Initialize app config service
        appConfigService = AppConfigService(
            remoteConfigService: RemoteConfigService()
        )

        Task {
            await initializeRemoteConfig()
        }
    }

    private func initializeRemoteConfig() async {
        guard let appConfigService = appConfigService else {
            return
        }

        do {
            _ = try await appConfigService.initialize()

            await MainActor.run {
                self.startDate = appConfigService.getEventStartDate()
                self.mainInfo = appConfigService.getMainInfo()
                self.isInitialized = true
            }
        } catch {
            print("Failed to initialize Remote Config: \(error)")
            // Use default values
            await MainActor.run {
                self.isInitialized = true
            }
        }
    }
}