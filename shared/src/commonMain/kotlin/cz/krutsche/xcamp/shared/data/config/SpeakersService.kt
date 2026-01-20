package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker
import io.github.aakira.napier.Napier

class SpeakersService {
    private val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }
    private val repository: SpeakersRepository by lazy {
        SpeakersRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService(),
            storageService = ServiceFactory.getStorageService()
        )
    }

    suspend fun getAllSpeakers(): List<Speaker> {
        Napier.d(tag = "SpeakersService") { "getAllSpeakers() - Fetching all speakers" }
        val result = repository.getAllSpeakers()
        Napier.i(tag = "SpeakersService") { "getAllSpeakers() - Returning ${result.size} speakers" }
        return result
    }

    suspend fun getSpeakerById(id: Long): Speaker? {
        Napier.d(tag = "SpeakersService") { "getSpeakerById($id) - Fetching speaker" }
        return repository.getSpeakerById(id)
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        Napier.d(tag = "SpeakersService") { "syncFromFirestore() - Starting sync" }
        return repository.syncFromFirestore()
    }

    suspend fun refreshSpeakers(): Result<List<Speaker>> {
        Napier.d(tag = "SpeakersService") { "refreshSpeakers() - Starting refresh" }
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = {
                    val speakers = getAllSpeakers()
                    Napier.i(tag = "SpeakersService") { "refreshSpeakers() - SUCCESS: Refreshed and returning ${speakers.size} speakers" }
                    Result.success(speakers)
                },
                onFailure = {
                    Napier.e(tag = "SpeakersService", throwable = it) { "refreshSpeakers() - FAILED: Sync failed" }
                    Result.failure(it)
                }
            )
        } catch (e: Exception) {
            Napier.e(tag = "SpeakersService", throwable = e) { "refreshSpeakers() - EXCEPTION: ${e.message}" }
            Result.failure(e)
        }
    }
}
