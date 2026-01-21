package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
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

    suspend fun getPlaceById(id: Long): Place? {
        return repository.getPlaceById(id)
    }

    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

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
}
