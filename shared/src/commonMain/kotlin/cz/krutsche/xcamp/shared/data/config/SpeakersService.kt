package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker

/**
 * Service for managing Speaker entities.
 *
 * Provides access to Speaker data from both local database and remote Firestore.
 * Extends [RepositoryService] for common repository initialization and sync functionality.
 *
 * @property repository The lazily initialized SpeakersRepository instance
 */
class SpeakersService : RepositoryService<SpeakersRepository>() {
    /**
     * Creates a new SpeakersRepository instance.
     *
     * @return A new SpeakersRepository with all required dependencies injected
     */
    override fun createRepository(): SpeakersRepository {
        return SpeakersRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService(),
            storageService = ServiceFactory.getStorageService()
        )
    }

    /**
     * Retrieves all speakers from the local database.
     *
     * @return List of all speakers, empty list if none exist
     */
    suspend fun getAllSpeakers(): List<Speaker> {
        return repository.getAllSpeakers()
    }

    /**
     * Retrieves a specific speaker by its uid.
     *
     * @param uid The uid of the speaker (Firebase document ID)
     * @return The speaker if found, null otherwise
     */
    suspend fun getSpeakerById(uid: String): Speaker? {
        return repository.getSpeakerById(uid)
    }

    /**
     * Synchronizes speaker data from Firestore to the local database.
     *
     * @return Result.Success on success, Result.Failure on error
     */
    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    /**
     * Refreshes speakers from Firestore and returns the updated list.
     *
     * Performs a sync from Firestore and returns all speakers from the local database.
     *
     * @return Result.Success containing the list of speakers, or Result.Failure on error
     */
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

    /**
     * Refreshes speakers from Firestore with fallback to cached data.
     *
     * Attempts to sync from Firestore but always returns local data if available.
     * This ensures the app remains functional even when offline.
     *
     * @return Result.Success containing the list of speakers (synced or cached), or Result.Failure if no cached data exists
     */
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
}
