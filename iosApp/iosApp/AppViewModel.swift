import SwiftUI
import shared
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var isInitialized = false
    @Published var appState: AppState = .limited
    @Published var availableTabs: [AppTab] = []

    private var xcampApp: XcampApp?

    func initializeApp() {
        let driverFactory = DatabaseDriverFactory()
        let databaseManager = DatabaseManager(driverFactory: driverFactory)
    }

    func refreshConfig() async {
    }
}