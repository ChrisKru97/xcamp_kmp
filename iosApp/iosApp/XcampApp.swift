import SwiftUI
import Firebase
import FirebaseCore
import shared
import Combine
import Kingfisher

// MARK: - Memory Warning Handler

/// Handles memory warnings by clearing the image cache
private class MemoryWarningHandler: ObservableObject {
    private var cancellable: AnyCancellable?

    init() {
        setupObserver()
    }

    private func setupObserver() {
        cancellable = NotificationCenter.default.publisher(
            for: UIApplication.didReceiveMemoryWarningNotification
        )
        .sink { [weak self] _ in
            guard let self = self else { return }
            // Kingfisher automatically manages memory, but we can clear on warning
            KingfisherManager.shared.cache.clearMemoryCache()
        }
    }

    deinit {
        cancellable?.cancel()
    }
}

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var memoryWarningHandler = MemoryWarningHandler()

    init() {
        // Initialize Firebase
        FirebaseApp.configure()

        // Kingfisher handles cache management automatically
        // Optional: Configure cache sizes here if needed
        // let cache = ImageCache.default
        // cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024  // 50MB
        // cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024  // 500MB
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
}
