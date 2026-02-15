package cz.krutsche.xcamp.shared.data.firebase

object AnalyticsHelper {
    fun setUserId(userId: String?) {
        AnalyticsService.setUserId(userId)
    }

    fun setUserProperty(name: String, value: String?) {
        AnalyticsService.setUserProperty(name, value)
    }

    fun logEvent(name: String, parameters: Map<String, String?> = emptyMap()) {
        AnalyticsService.logEvent(name, parameters)
    }
}
