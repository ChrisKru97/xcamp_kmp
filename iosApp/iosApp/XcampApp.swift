import SwiftUI
import Firebase
import FirebaseCore
import shared
import OSLog
import Combine

// MARK: - Memory Warning Handler

/// Handles memory warnings by clearing the image cache
private class MemoryWarningHandler: ObservableObject {
    private var cancellable: AnyCancellable?
    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "MemoryWarningHandler")

    init() {
        setupObserver()
    }

    private func setupObserver() {
        logger.debug("MemoryWarningHandler.setupObserver() - Setting up memory warning observer")

        cancellable = NotificationCenter.default.publisher(
            for: UIApplication.didReceiveMemoryWarningNotification
        )
        .sink { [weak self] _ in
            guard let self = self else { return }

            self.logger.warning("MemoryWarningHandler.didReceiveMemoryWarning() - Memory warning received, clearing ImageCache")
            ImageCache.shared.clearCache()

            // Also clean up expired entries
            self.logger.debug("MemoryWarningHandler.didReceiveMemoryWarning() - Cleaning up expired entries")
            ImageCache.shared.cleanupExpiredEntries()
        }

        logger.info("MemoryWarningHandler.setupObserver() - Memory warning observer registered")
    }

    deinit {
        cancellable?.cancel()
    }
}

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var memoryWarningHandler = MemoryWarningHandler()

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "XcampApp")

    init() {
        logger.debug("XcampApp.init() - Starting app initialization")

        // Initialize Napier logging first so we can see debug output
        logger.debug("XcampApp.init() - Initializing Napier logger")
        LoggerInitializerKt.initializeLogger()
        logger.debug("XcampApp.init() - Napier logger initialized")

        // Then initialize Firebase
        logger.debug("XcampApp.init() - Configuring Firebase...")
        FirebaseApp.configure()
        logger.info("XcampApp.init() - Firebase configured successfully")

        // Verify Firebase is configured
        if let firebaseApp = FirebaseApp.app() {
            logger.debug("XcampApp.init() - Firebase app name: \(firebaseApp.name)")
            logger.debug("XcampApp.init() - Firebase GoogleAppID: \(firebaseApp.options.googleAppID)")
            logger.debug("XcampApp.init() - Firebase GCM Sender ID: \(firebaseApp.options.gcmSenderID)")
            if let projectID = firebaseApp.options.projectID {
                logger.debug("XcampApp.init() - Firebase Project ID: \(projectID)")
            } else {
                logger.debug("XcampApp.init() - Firebase Project ID: not configured")
            }
            logger.info("XcampApp.init() - Firebase app is ready")
        } else {
            logger.error("XcampApp.init() - Firebase app is nil after configuration!")
        }

        logger.debug("XcampApp.init() - App initialization complete")

        // Clean up expired image cache entries on app launch
        logger.debug("XcampApp.init() - Cleaning up expired image cache entries")
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
