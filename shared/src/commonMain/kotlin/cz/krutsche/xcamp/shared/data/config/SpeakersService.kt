package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker

class SpeakersService {
    private val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }
    private val repository: SpeakersRepository by lazy {
        SpeakersRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService()
        )
    }

    suspend fun getAllSpeakers(): List<Speaker> {
        return repository.getAllSpeakers()
    }

    suspend fun getSpeakerById(id: Long): Speaker? {
        return repository.getSpeakerById(id)
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    suspend fun refreshSpeakers(): Result<List<Speaker>> {
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = { Result.success(getAllSpeakers()) },
                onFailure = { Result.failure(it) }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
