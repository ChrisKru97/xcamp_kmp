import Foundation
import UIKit
import FirebaseMessaging
import UserNotifications

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate, MessagingDelegate, UIApplicationDelegate {
    @Published var fcmToken: String?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[APNs] Failed to register: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }

        Task { @MainActor in
            self.fcmToken = token
            print("[FCM] Token refreshed: \(token.prefix(10))...")
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[Notification] Tapped with userInfo: \(userInfo)")

        guard let type = userInfo["type"] as? String,
              type == "section",
              let sectionUid = userInfo["sectionId"] as? String else {
            completionHandler()
            return
        }

        Task { @MainActor in
            NotificationCenter.default.post(
                name: .navigateToSection,
                object: nil,
                userInfo: ["sectionUid": sectionUid]
            )
        }

        completionHandler()
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

extension Notification.Name {
    static let navigateToSection = Notification.Name("navigateToSection")
}