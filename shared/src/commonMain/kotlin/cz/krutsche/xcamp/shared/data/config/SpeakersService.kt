package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker
import io.github.aakira.napier.Napier

class SpeakersService : RepositoryService<SpeakersRepository>() {
    override fun createRepository(): SpeakersRepository {
        return SpeakersRepository(
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

    override suspend fun syncFromFirestore(): Result<Unit> {
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
