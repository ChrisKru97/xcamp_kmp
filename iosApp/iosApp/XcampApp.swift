import SwiftUI
import shared
import Firebase
import FirebaseAuth
import FirebaseCrashlytics
import Kingfisher

@main
struct XcampApp: App {
    @UIApplicationDelegateAdaptor(NotificationDelegate.self) var notificationDelegate
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(router)
                .onAppear {
                    configureFirebase()
                    configureKingfisherCache()
                    appViewModel.initialize(notificationDelegate: notificationDelegate)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Task {
                        await appViewModel.checkForceUpdateOnForeground()
                    }
                }
        }
    }

    private func configureFirebase() {
        FirebaseApp.configure()
        configureCrashlytics()
        configureAnalytics()
    }

    private func configureCrashlytics() {
        let enabled = AppPreferences.shared.getDataCollectionEnabled()
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCrashlyticsCollectionEnabled(enabled)

        guard enabled else { return }

        let platform = Platform()

        crashlytics.setCustomValue(platform.appVersion, forKey: "app_version")
        crashlytics.setCustomValue(platform.buildNumber, forKey: "build_number")
        crashlytics.setCustomValue(platform.buildType, forKey: "build_type")
        crashlytics.setCustomValue(platform.version, forKey: "os_version")
        crashlytics.setCustomValue(platform.model, forKey: "device_model")
        crashlytics.setCustomValue(platform.name, forKey: "device_name")
        crashlytics.setCustomValue(platform.locale, forKey: "locale")
        crashlytics.setCustomValue(platform.screenSize, forKey: "screen_size")
        crashlytics.setCustomValue(platform.systemName, forKey: "system_name")

        if let userID = Auth.auth().currentUser?.uid {
            crashlytics.setUserID(userID)
        }
    }

    private func configureAnalytics() {
        let enabled = AppPreferences.shared.getDataCollectionEnabled()
        Analytics.setAnalyticsCollectionEnabled(enabled)

        guard enabled else { return }

        let platform = Platform()

        Analytics.shared.setUserProperty(name: "app_version", value: platform.appVersion)
        Analytics.shared.setUserProperty(name: "build_type", value: platform.buildType)
        Analytics.shared.setUserProperty(name: "locale", value: platform.locale)

        if let userID = Auth.auth().currentUser?.uid {
            Analytics.shared.setUserId(userId: userID)
        }
    }

    private func configureKingfisherCache() {
        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(30)
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
    }
}
