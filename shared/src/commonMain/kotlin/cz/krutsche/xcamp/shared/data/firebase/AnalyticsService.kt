package cz.krutsche.xcamp.shared.data.firebase

expect object AnalyticsService {
    fun logEvent(name: String, parameters: Map<String, String?> = emptyMap())
    fun setUserId(userId: String?)
    fun setUserProperty(name: String, value: String?)
    fun resetAnalyticsData()
}
