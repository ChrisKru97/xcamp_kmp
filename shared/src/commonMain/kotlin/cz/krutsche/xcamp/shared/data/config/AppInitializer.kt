package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.Platform
import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.local.EntityType
import dev.gitlive.firebase.firestore.firestore
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class AppInitializer(
    private val appConfigService: AppConfigService,
    private val platform: Platform
) {
    private val authService = ServiceFactory.getAuthService()
    private val notificationService = ServiceFactory.getNotificationService()

    suspend fun initialize(): Result<Unit> = try {
        initializeRemoteConfig()
        initializeAuth()
        
        registerUserDevice()

        verifyFirestoreAccess()

        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }

    private suspend fun initializeRemoteConfig() = withTimeout(10.seconds) {
        appConfigService.initialize()
    }

    private suspend fun initializeAuth() = withTimeout(DEFAULT_TIMEOUT) {
        authService.initialize()
    }

    private suspend fun registerUserDevice(): Result<Unit> {
        val fcmToken = notificationService.getFCMToken()
        return authService.registerUserWithDevice(platform, fcmToken)
    }

    private suspend fun verifyFirestoreAccess() {
        try {
            withTimeout(DEFAULT_TIMEOUT) {
                dev.gitlive.firebase.Firebase.firestore.collection(EntityType.SPEAKERS.collectionName).limit(1).get()
            }
        } catch (e: Exception) {
            println("Firestore access verification failed: ${e.message}")
        }
    }

}
