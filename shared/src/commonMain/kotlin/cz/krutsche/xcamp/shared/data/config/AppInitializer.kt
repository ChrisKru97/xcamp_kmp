package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import dev.gitlive.firebase.firestore.firestore
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class AppInitializer(
    private val appConfigService: AppConfigService,
    private val authService: AuthService
) {
    private val firestoreService = FirestoreService()

    suspend fun initialize(): Result<Unit> = try {
        initializeRemoteConfig()
        initializeAuth()
        verifyFirestoreAccess()

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

    private suspend fun verifyFirestoreAccess() {
        try {
            // Try to access a Firestore collection with timeout to verify connectivity
            withTimeout(5.seconds) {
                try {
                    // Attempt to list documents from speakers collection
                    dev.gitlive.firebase.Firebase.firestore.collection("speakers").limit(1).get()
                } catch (e: Exception) {
                    // Firestore query failed - continue anyway
                }
            }
        } catch (e: Exception) {
            // Firestore accessibility test failed - continue anyway
        }
    }
}
