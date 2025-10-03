package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.AuthService

class AppInitializer(
    private val appConfigService: AppConfigService,
    private val authService: AuthService
) {
    suspend fun initialize(): Result<Unit> = try {
        initializeRemoteConfig()
        initializeAuth()

        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }

    private suspend fun initializeRemoteConfig() {
        appConfigService.initialize()
    }

    private suspend fun initializeAuth() {
        authService.initialize()
    }
}