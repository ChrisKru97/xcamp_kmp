import SwiftUI
import Firebase
import FirebaseCore
import shared
import Combine

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
            ImageCache.shared.clearCache()

            // Also clean up expired entries
            ImageCache.shared.cleanupExpiredEntries()
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

        // Clean up expired image cache entries on app launch
        ImageCache.shared.cleanupExpiredEntries()
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
