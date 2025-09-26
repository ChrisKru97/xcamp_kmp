package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.AnalyticsService
import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService
import cz.krutsche.xcamp.shared.data.firebase.FirebaseConfig

class AppInitializer(
    private val appConfigService: AppConfigService,
    private val authService: AuthService,
    private val analyticsService: AnalyticsService,
    private val crashlyticsService: CrashlyticsService
) {
    suspend fun initialize(): Result<Unit> = try {
        crashlyticsService.log("XcamP app initialization started")

        initializeFirebase()
        initializeRemoteConfig()
        initializeAuth()

        crashlyticsService.log("XcamP app initialization completed successfully")
        Result.success(Unit)
    } catch (e: Exception) {
        crashlyticsService.recordException(e, "XcamP app initialization failed")
        Result.failure(e)
    }

    private fun initializeFirebase() {
        FirebaseConfig.initialize()
        crashlyticsService.log("Firebase initialized")
    }

    private suspend fun initializeRemoteConfig() {
        appConfigService.initialize().fold(
            onSuccess = {
                crashlyticsService.log("Remote Config initialized successfully")
            },
            onFailure = { error ->
                crashlyticsService.log("Remote Config initialization failed: ${error.message}")
            }
        )
    }

    private suspend fun initializeAuth() {
        authService.signInAnonymously().fold(
            onSuccess = { userId ->
                analyticsService.setUserId(userId)
                crashlyticsService.setUserId(userId)
                crashlyticsService.log("Anonymous authentication successful: $userId")
            },
            onFailure = { error ->
                crashlyticsService.recordException(error, "Anonymous authentication failed")
            }
        )
    }
}