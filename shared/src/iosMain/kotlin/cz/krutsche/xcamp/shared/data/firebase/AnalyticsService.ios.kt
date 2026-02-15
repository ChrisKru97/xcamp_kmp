package cz.krutsche.xcamp.shared.data.firebase

import analytics.bridge.AnalyticsBridge
import platform.Foundation.NSDictionary
import platform.Foundation.NSString
import kotlinx.cinterop.ExperimentalForeignApi

@OptIn(ExperimentalForeignApi::class)
actual object AnalyticsService {
    private val bridge by lazy { AnalyticsBridge.shared() }

    actual fun logEvent(name: String, parameters: Map<String, String?>) {
        val nsParams = parameters.filterValues { it != null } as Map<Any?, Any?>
        bridge?.logEvent(name, parameters = nsParams)
    }

    actual fun setUserId(userId: String?) {
        userId?.let { bridge?.setUserId(it) }
    }

    actual fun setUserProperty(name: String, value: String?) {
        bridge?.setUserProperty(name, value = value)
    }

    actual fun resetAnalyticsData() {
        bridge?.resetAnalyticsData()
    }
}
