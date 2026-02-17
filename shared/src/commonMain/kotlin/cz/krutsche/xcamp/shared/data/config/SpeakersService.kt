package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker

class SpeakersService : RepositoryService<SpeakersRepository>() {
    override fun createRepository(): SpeakersRepository {
        return SpeakersRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService(),
            storageService = ServiceFactory.getStorageService()
        )
    }

    suspend fun getAllSpeakers(): List<Speaker> {
        return repository.getAllSpeakers()
    }

    suspend fun getSpeakerById(uid: String): Speaker? {
        return repository.getSpeakerById(uid)
    }

    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    suspend fun refreshSpeakers(): Result<List<Speaker>> {
        val syncResult = syncFromFirestore()
        return syncResult.fold(
            onSuccess = {
                val speakers = getAllSpeakers()
                Result.success(speakers)
            },
            onFailure = {
                Result.failure(it)
            }
        )
    }

    suspend fun refreshSpeakersWithFallback(): Result<List<Speaker>> {
        val syncResult = syncFromFirestore()
        val speakers = getAllSpeakers()

        return syncResult.fold(
            onSuccess = { Result.success(speakers) },
            onFailure = { error ->
                if (speakers.isNotEmpty()) {
                    Result.success(speakers)
                } else {
                    Result.failure(error)
                }
            }
        )
    }

    suspend fun isDataStale(maxAgeMs: Long = DEFAULT_STALENESS_MS): Boolean {
        return repository.isDataStale(maxAgeMs)
    }

    suspend fun hasCachedData(): Boolean {
        return repository.hasCachedData()
    }
}
