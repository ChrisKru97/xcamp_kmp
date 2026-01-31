package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.domain.model.Place

/**
 * Service for managing Place entities.
 *
 * Provides access to Place data from both local database and remote Firestore.
 * Extends [RepositoryService] for common repository initialization and sync functionality.
 *
 * @property repository The lazily initialized PlacesRepository instance
 */
class PlacesService : RepositoryService<PlacesRepository>() {
    /**
     * Creates a new PlacesRepository instance.
     *
     * @return A new PlacesRepository with all required dependencies injected
     */
    override fun createRepository(): PlacesRepository {
        return PlacesRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService(),
            storageService = ServiceFactory.getStorageService()
        )
    }

    /**
     * Retrieves all places from the local database.
     *
     * @return List of all places, empty list if none exist
     */
    suspend fun getAllPlaces(): List<Place> {
        return repository.getAllPlaces()
    }

    /**
     * Retrieves a specific place by its uid.
     *
     * @param uid The uid of the place (Firebase document ID)
     * @return The place if found, null otherwise
     */
    suspend fun getPlaceById(uid: String): Place? {
        return repository.getPlaceById(uid)
    }

    /**
     * Synchronizes place data from Firestore to the local database.
     *
     * @return Result.Success on success, Result.Failure on error
     */
    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    /**
     * Refreshes places from Firestore and returns the updated list.
     *
     * Performs a sync from Firestore and returns all places from the local database.
     *
     * @return Result.Success containing the list of places, or Result.Failure on error
     */
    suspend fun refreshPlaces(): Result<List<Place>> {
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = { Result.success(getAllPlaces()) },
                onFailure = { Result.failure(it) }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getArealImageURL(): String? {
        return repository.getArealImageURL()
    }
}
