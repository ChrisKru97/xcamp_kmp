package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.data.repository.SyncError
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
     * @return Result.Success with the place if found, Result.Failure if not found or on error
     */
    suspend fun getPlaceById(uid: String): Result<Place> {
        val place = repository.getPlaceById(uid)
        return if (place != null) {
            Result.success(place)
        } else {
            Result.failure(SyncError.EmptyCacheError)
        }
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
        val syncResult = syncFromFirestore()
        return syncResult.fold(
            onSuccess = { Result.success(getAllPlaces()) },
            onFailure = { Result.failure(it) }
        )
    }

    /**
     * Refreshes places from Firestore with fallback to cached data.
     *
     * Attempts to sync from Firestore but always returns local data if available.
     * This ensures the app remains functional even when offline.
     *
     * @return Result.Success containing the list of places (synced or cached), or Result.Failure if no cached data exists
     */
    suspend fun refreshPlacesWithFallback(): Result<List<Place>> {
        val syncResult = syncFromFirestore()
        val places = getAllPlaces()

        return syncResult.fold(
            onSuccess = { Result.success(places) },
            onFailure = { error ->
                if (places.isNotEmpty()) {
                    Result.success(places)
                } else {
                    Result.failure(error)
                }
            }
        )
    }

    /**
     * Checks if the places data is stale (older than maxAgeMs).
     *
     * @param maxAgeMs Maximum age in milliseconds (default: 24 hours)
     * @return true if data is stale or doesn't exist, false otherwise
     */
    suspend fun isDataStale(maxAgeMs: Long = DEFAULT_STALENESS_MS): Boolean {
        return repository.isDataStale(maxAgeMs)
    }

    /**
     * Checks if there is cached places data available.
     *
     * @return true if cached data exists, false otherwise
     */
    suspend fun hasCachedData(): Boolean {
        return repository.hasCachedData()
    }

    /**
     * Gets the areal (map) image URL with proper error handling.
     *
     * @return Result.Success with the URL, or Result.Failure on error
     */
    suspend fun getArealImageURL(): Result<String> {
        return repository.getArealImageURL()
    }
}
