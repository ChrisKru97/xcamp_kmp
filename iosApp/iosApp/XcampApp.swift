import SwiftUI
import Firebase
import FirebaseCore
import shared
import OSLog
import Combine
import os.signpost

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

// MARK: - Startup Performance Signposts

private extension OSLog {
    /// Signpost log for startup performance instrumentation
    static let startup = OSLog(subsystem: "com.krutsche.xcamp", category: "StartupPerformance")
}

/// Signpost IDs for tracking startup events
private let startupSignpostID = OSSignpostID(log: OSLog.startup)

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var memoryWarningHandler = MemoryWarningHandler()

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "XcampApp")

    init() {
        // MARK: - App Initialization Start
        let initStart = DispatchTime.now()
        os_signpost(.begin, log: OSLog.startup, name: "AppInitialization", signpostID: startupSignpostID)

        logger.debug("XcampApp.init() - Starting app initialization")

        // Initialize Napier logging first so we can see debug output
        os_signpost(.begin, log: OSLog.startup, name: "NapierInit", signpostID: startupSignpostID)
        logger.debug("XcampApp.init() - Initializing Napier logger")
        LoggerInitializerKt.initializeLogger()
        logger.debug("XcampApp.init() - Napier logger initialized")
        os_signpost(.end, log: OSLog.startup, name: "NapierInit", signpostID: startupSignpostID)

        // Then initialize Firebase
        os_signpost(.begin, log: OSLog.startup, name: "FirebaseInit", signpostID: startupSignpostID)
        logger.debug("XcampApp.init() - Configuring Firebase...")
        FirebaseApp.configure()
        logger.info("XcampApp.init() - Firebase configured successfully")
        os_signpost(.end, log: OSLog.startup, name: "FirebaseInit", signpostID: startupSignpostID)

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

        // Clean up expired image cache entries on app launch
        logger.debug("XcampApp.init() - Cleaning up expired image cache entries")
        ImageCache.shared.cleanupExpiredEntries()

        let initEnd = DispatchTime.now()
        let initTime = Double(initEnd.uptimeNanoseconds - initStart.uptimeNanoseconds) / 1_000_000
        logger.info("XcampApp.init() - App initialization complete in \(initTime, format: .fixed(precision: 2))ms")
        os_signpost(.end, log: OSLog.startup, name: "AppInitialization", signpostID: startupSignpostID)
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
