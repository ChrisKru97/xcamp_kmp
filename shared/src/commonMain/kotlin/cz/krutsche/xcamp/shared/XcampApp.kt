package cz.krutsche.xcamp.shared

import cz.krutsche.xcamp.shared.data.config.AppConfigService
import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.FirebaseConfig
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsService
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager

/**
 * Main XcamP application class that initializes all services
 * This is the entry point for the shared business logic
 */
class XcampApp(
    private val databaseManager: DatabaseManager,
    private val appConfigService: AppConfigService,
    private val authService: AuthService,
    private val analyticsService: AnalyticsService,
    private val crashlyticsService: CrashlyticsService
) {

    suspend fun initialize(): Result<Unit> {
        return try {
            crashlyticsService.log("XcamP app initialization started")

            // Initialize Firebase
            FirebaseConfig.initialize()
            crashlyticsService.log("Firebase initialized")

            // Initialize Remote Config
            appConfigService.initialize().fold(
                onSuccess = {
                    crashlyticsService.log("Remote Config initialized successfully")
                },
                onFailure = { error ->
                    crashlyticsService.log("Remote Config initialization failed: ${error.message}")
                    // Continue with app initialization even if Remote Config fails
                }
            )

            // Sign in anonymously to Firebase Auth
            authService.signInAnonymously().fold(
                onSuccess = { userId ->
                    analyticsService.setUserId(userId)
                    crashlyticsService.setUserId(userId)
                    crashlyticsService.log("Anonymous authentication successful: $userId")
                },
                onFailure = { error ->
                    crashlyticsService.recordException(error, "Anonymous authentication failed")
                    // Continue with app initialization even if auth fails
                }
            )

            crashlyticsService.log("XcamP app initialization completed successfully")
            Result.success(Unit)

        } catch (e: Exception) {
            crashlyticsService.recordException(e, "XcamP app initialization failed")
            Result.failure(e)
        }
    }

    fun getAppState() = appConfigService.getAppState()

    fun getAvailableTabs() = appConfigService.getAvailableTabs()

    fun shouldShowAppData() = appConfigService.shouldShowAppData()

    fun isEventActive() = appConfigService.isEventActive()

    fun isEventOver() = appConfigService.isEventOver()

    suspend fun refreshConfig(): Result<Unit> {
        return appConfigService.refresh()
    }

    fun getCurrentUserId(): String? {
        return authService.getCurrentUserId()
    }

    fun logAnalyticsEvent(eventName: String, parameters: Map<String, Any> = emptyMap()) {
        analyticsService.logEvent(eventName, parameters)
    }

    fun logMessage(message: String) {
        crashlyticsService.log(message)
    }

    fun recordException(throwable: Throwable, message: String? = null) {
        crashlyticsService.recordException(throwable, message)
    }
}