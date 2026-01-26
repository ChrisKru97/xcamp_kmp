import SwiftUI
import Firebase
import Kingfisher

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()

    init() {
        FirebaseApp.configure()
        configureKingfisherCache()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .onAppear {
                    appViewModel.initializeApp()
                }
        }
    }

    private func configureKingfisherCache() {
        let cache = ImageCache.default

        // Configure disk cache with 30-day expiration for stale-while-revalidate pattern
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024  // 300 MB
        cache.diskStorage.config.expiration = .days(30)

        // Keep memory cache at 300 MB for instant access during app session
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024  // 300 MB
    }
}
