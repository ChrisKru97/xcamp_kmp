package cz.krutsche.xcamp.shared

import cz.krutsche.xcamp.shared.data.config.AppConfigService
import cz.krutsche.xcamp.shared.data.config.AppInitializer
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsService
import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService

class XcampApp(
    private val appConfigService: AppConfigService,
    private val authService: AuthService,
    private val analyticsService: AnalyticsService,
    private val crashlyticsService: CrashlyticsService,
    private val appInitializer: AppInitializer
) {
    suspend fun initialize(): Result<Unit> = appInitializer.initialize()

    fun getAppState() = appConfigService.getAppState()
    fun getAvailableTabs() = appConfigService.getAvailableTabs()
    fun shouldShowAppData() = appConfigService.shouldShowAppData()
    fun isEventActive() = appConfigService.isEventActive()
    fun isEventOver() = appConfigService.isEventOver()

    suspend fun refreshConfig(): Result<Unit> = appConfigService.refresh()

    fun getCurrentUserId(): String? = authService.currentUserId

    fun logAnalyticsEvent(eventName: String, parameters: Map<String, Any> = emptyMap()) =
        analyticsService.logEvent(eventName, parameters)

    fun logMessage(message: String) = crashlyticsService.log(message)

    fun recordException(throwable: Throwable, message: String? = null) =
        crashlyticsService.recordException(throwable, message)
}