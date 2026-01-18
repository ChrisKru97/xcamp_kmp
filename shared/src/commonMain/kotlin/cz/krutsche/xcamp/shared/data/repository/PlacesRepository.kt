package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Place

class PlacesRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Place>(databaseManager, firestoreService) {

    override val collectionName = "places"

    suspend fun getAllPlaces(): List<Place> = withDatabase {
        queries.selectAllPlaces().executeAsList().map(::mapToPlace)
    }

    suspend fun getPlaceById(id: Long): Place? = withDatabase {
        queries.selectPlaceById(id).executeAsOneOrNull()?.let(::mapToPlace)
    }

    suspend fun insertPlaces(places: List<Place>) = withDatabase {
        queries.transaction {
            places.forEach { place ->
                queries.insertPlace(
                    id = place.id,
                    uid = place.uid,
                    name = place.name,
                    description = place.description,
                    priority = place.priority,
                    latitude = place.latitude,
                    longitude = place.longitude,
                    image = place.image,
                    imageUrl = place.imageUrl
                )
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> =
        syncFromFirestore(Place.serializer(), ::insertPlaces)

    private fun mapToPlace(dbPlace: cz.krutsche.xcamp.shared.db.Place): Place =
        cz.krutsche.xcamp.shared.domain.model.Place(
            id = dbPlace.id,
            uid = dbPlace.uid,
            name = dbPlace.name,
            description = dbPlace.description,
            priority = dbPlace.priority,
            latitude = dbPlace.latitude,
            longitude = dbPlace.longitude,
            image = dbPlace.image,
            imageUrl = dbPlace.imageUrl
        )
}
