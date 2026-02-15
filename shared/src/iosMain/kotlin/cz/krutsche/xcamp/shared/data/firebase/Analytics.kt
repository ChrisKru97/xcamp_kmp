package cz.krutsche.xcamp.shared.data.firebase

object Analytics {
    fun logEvent(name: String, parameters: Map<String, String?> = emptyMap()) {
        AnalyticsService.logEvent(name, parameters)
    }

    fun logScreenView(screenName: String) {
        AnalyticsService.logEvent(
            name = AnalyticsEvents.SCREEN_VIEW,
            parameters = mapOf(
                AnalyticsEvents.PARAM_SCREEN_NAME to screenName
            )
        )
    }

    fun setUserId(userId: String?) {
        AnalyticsService.setUserId(userId)
    }

    fun setUserProperty(name: String, value: String?) {
        AnalyticsService.setUserProperty(name, value)
    }

    fun resetAnalyticsData() {
        AnalyticsService.resetAnalyticsData()
    }
}
