package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.AuthService
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import dev.gitlive.firebase.firestore.firestore
import io.github.aakira.napier.Napier
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
        Napier.e(tag = "AppInitializer", throwable = e) { "initialize() - Failed: ${e.message}" }
        Result.failure(e)
    }

    private suspend fun initializeRemoteConfig() {
        Napier.d(tag = "AppInitializer") { "initializeRemoteConfig() - Starting" }
        appConfigService.initialize()
        Napier.i(tag = "AppInitializer") { "initializeRemoteConfig() - Complete" }
    }

    private suspend fun initializeAuth() {
        Napier.d(tag = "AppInitializer") { "initializeAuth() - Starting" }
        authService.initialize()
        Napier.i(tag = "AppInitializer") { "initializeAuth() - Complete" }
    }

    private suspend fun verifyFirestoreAccess() {
        Napier.d(tag = "AppInitializer") { "verifyFirestoreAccess() - Starting Firestore accessibility test" }
        try {
            // Try to access a Firestore collection with timeout to verify connectivity
            val result = withTimeout(5.seconds) {
                try {
                    // Attempt to list documents from speakers collection
                    val querySnapshot = dev.gitlive.firebase.Firebase.firestore.collection("speakers").limit(1).get()
                    val count = querySnapshot.documents.size
                    Napier.i(tag = "AppInitializer") { "verifyFirestoreAccess() - Firestore is accessible! Found $count document(s) in 'speakers' collection" }
                    true
                } catch (e: Exception) {
                    Napier.w(tag = "AppInitializer", throwable = e) { "verifyFirestoreAccess() - Firestore query failed: ${e.message}" }
                    false
                }
            }
            if (result) {
                Napier.i(tag = "AppInitializer") { "verifyFirestoreAccess() - SUCCESS: Firestore is accessible and responding" }
            } else {
                Napier.w(tag = "AppInitializer") { "verifyFirestoreAccess() - WARNING: Firestore query returned no results (might be empty collection or permission issue)" }
            }
        } catch (e: Exception) {
            Napier.w(tag = "AppInitializer", throwable = e) { "verifyFirestoreAccess() - Firestore accessibility test failed: ${e.message}" }
            Napier.w(tag = "AppInitializer") { "verifyFirestoreAccess() - Continuing anyway - data sync will attempt to fetch real data" }
        }
    }
}
