import SwiftUI
import Firebase
import Kingfisher

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var router = AppRouter()

    init() {
        FirebaseApp.configure()
        configureKingfisherCache()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(router)
                .onAppear {
                    appViewModel.initializeApp()
                }
        }
    }

    private func configureKingfisherCache() {
        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(30)
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
    }
}
