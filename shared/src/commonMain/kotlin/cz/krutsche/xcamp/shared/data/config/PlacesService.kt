package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.data.repository.NotFoundError
import cz.krutsche.xcamp.shared.domain.model.Place

class PlacesService : RepositoryService<PlacesRepository>() {
    override fun createRepository(): PlacesRepository {
        return PlacesRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService(),
            storageService = ServiceFactory.getStorageService()
        )
    }

    suspend fun getAllPlaces(): List<Place> {
        return repository.getAllPlaces()
    }

    suspend fun getPlaceById(uid: String): Result<Place> {
        val place = repository.getPlaceById(uid)
        return if (place != null) {
            Result.success(place)
        } else {
            Result.failure(NotFoundError)
        }
    }

    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    suspend fun refreshPlaces(): Result<List<Place>> {
        val syncResult = syncFromFirestore()
        return syncResult.fold(
            onSuccess = { Result.success(getAllPlaces()) },
            onFailure = { Result.failure(it) }
        )
    }

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

    suspend fun isDataStale(maxAgeMs: Long = DEFAULT_STALENESS_MS): Boolean {
        return repository.isDataStale(maxAgeMs)
    }

    suspend fun hasCachedData(): Boolean {
        return repository.hasCachedData()
    }

    suspend fun getArealImageURL(): Result<String> {
        return repository.getArealImageURL()
    }
}
