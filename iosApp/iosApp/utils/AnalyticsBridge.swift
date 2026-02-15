import Foundation
import FirebaseAnalytics

@objc(AnalyticsBridge)
public class AnalyticsBridgeImpl: NSObject {
    @objc public static func shared() -> AnalyticsBridgeImpl {
        return AnalyticsBridgeImpl()
    }

    private let analytics: Analytics

    public override init() {
        self.analytics = Analytics.analytics()
        super.init()
    }

    @objc public func logEvent(_ name: String, parameters: [String: String]?) {
        analytics.logEvent(name, parameters: parameters)
    }

    @objc public func setUserId(_ userId: String?) {
        analytics.setUserID(userId)
    }

    @objc public func setUserProperty(_ name: String, value: String?) {
        analytics.setUserProperty(value, forName: name)
    }

    @objc public func resetAnalyticsData() {
        analytics.resetAnalyticsData()
    }
}
