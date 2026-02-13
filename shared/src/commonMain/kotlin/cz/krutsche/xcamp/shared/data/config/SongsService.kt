package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.SongsRepository
import cz.krutsche.xcamp.shared.domain.model.Song

class SongsService : RepositoryService<SongsRepository>() {

    override fun createRepository(): SongsRepository {
        return SongsRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService()
        )
    }

    suspend fun getAllSongs(): List<Song> {
        return repository.getAllSongs()
    }

    suspend fun getSongByNumber(number: Long): Song? {
        return repository.getSongByNumber(number)
    }

    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    suspend fun refreshSongs(): Result<List<Song>> {
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = { Result.success(getAllSongs()) },
                onFailure = { Result.failure(it) }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun refreshSongsWithFallback(): Result<List<Song>> {
        val syncResult = syncFromFirestore()
        val songs = getAllSongs()

        return syncResult.fold(
            onSuccess = { Result.success(songs) },
            onFailure = { error ->
                if (songs.isNotEmpty()) {
                    Result.success(songs)
                } else {
                    Result.failure(error)
                }
            }
        )
    }

    suspend fun hasCachedData(): Boolean {
        return repository.hasCachedData()
    }

    suspend fun isDataStale(maxAgeMs: Long = DEFAULT_STALENESS_MS): Boolean {
        return repository.isDataStale(maxAgeMs)
    }
}
