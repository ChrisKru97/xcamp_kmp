import Foundation
import FirebaseCrashlytics

// Implementation of CrashlyticsBridge interface
// This class is called by Kotlin shared code via cinterop
@objc(CrashlyticsBridge)
public class CrashlyticsBridgeImpl: NSObject {

    @objc public static func shared() -> CrashlyticsBridgeImpl {
        return CrashlyticsBridgeImpl()
    }

    @objc public func setUserId(_ userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }

    @objc public func setCustomKey(_ key: String, value: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }

    @objc public func recordException(_ message: String) {
        let error = NSError(domain: "CzKrutscheXcamp", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
        Crashlytics.crashlytics().record(error: error)
    }

    @objc public func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}
