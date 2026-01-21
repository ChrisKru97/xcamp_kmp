package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.SpeakersRepository
import cz.krutsche.xcamp.shared.domain.model.Speaker
import io.github.aakira.napier.Napier

/**
 * Service for managing Speaker entities.
 *
 * Provides access to Speaker data from both local database and remote Firestore.
 * Extends [RepositoryService] for common repository initialization and sync functionality.
 * Uses Napier for logging operations.
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
        Napier.d(tag = "SpeakersService") { "getAllSpeakers() - Fetching all speakers" }
        val result = repository.getAllSpeakers()
        Napier.i(tag = "SpeakersService") { "getAllSpeakers() - Returning ${result.size} speakers" }
        return result
    }

    /**
     * Retrieves a specific speaker by its numeric ID.
     *
     * @param id The numeric ID of the speaker (generated from document ID)
     * @return The speaker if found, null otherwise
     */
    suspend fun getSpeakerById(id: Long): Speaker? {
        Napier.d(tag = "SpeakersService") { "getSpeakerById($id) - Fetching speaker" }
        return repository.getSpeakerById(id)
    }

    /**
     * Synchronizes speaker data from Firestore to the local database.
     *
     * @return Result.Success on success, Result.Failure on error
     */
    override suspend fun syncFromFirestore(): Result<Unit> {
        Napier.d(tag = "SpeakersService") { "syncFromFirestore() - Starting sync" }
        return repository.syncFromFirestore()
    }

    /**
     * Refreshes speakers from Firestore and returns the updated list.
     *
     * Performs a sync from Firestore and returns all speakers from the local database.
     * Logs the number of speakers refreshed on success.
     *
     * @return Result.Success containing the list of speakers, or Result.Failure on error
     */
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
