package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.repository.PlacesRepository
import cz.krutsche.xcamp.shared.domain.model.Place

class PlacesService {
    private val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }
    private val repository: PlacesRepository by lazy {
        PlacesRepository(
            databaseManager = databaseManager,
            firestoreService = cz.krutsche.xcamp.shared.data.firebase.FirestoreService()
        )
    }

    suspend fun getAllPlaces(): List<Place> {
        return repository.getAllPlaces()
    }

    suspend fun getPlaceById(id: Long): Place? {
        return repository.getPlaceById(id)
    }

    suspend fun syncFromFirestore(): Result<Unit> {
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
