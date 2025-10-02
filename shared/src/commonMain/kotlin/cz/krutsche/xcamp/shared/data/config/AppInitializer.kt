package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.FirebaseConfig

class AppInitializer(
    private val appConfigService: AppConfigService,
    private val authService: AuthService
) {
    suspend fun initialize(): Result<Unit> = try {
        initializeFirebase()
        initializeRemoteConfig()
        initializeAuth()

        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }

    private fun initializeFirebase() {
        FirebaseConfig.initialize()
    }

    private suspend fun initializeRemoteConfig() {
        appConfigService.initialize()
    }

    private suspend fun initializeAuth() {
        authService.initialize()
    }
}