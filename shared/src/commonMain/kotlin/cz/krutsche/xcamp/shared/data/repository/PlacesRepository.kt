package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.FirestorePlace
import cz.krutsche.xcamp.shared.domain.model.Place
import cz.krutsche.xcamp.shared.domain.model.toDbPlace
import io.github.aakira.napier.Napier

class PlacesRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Place>(databaseManager, firestoreService) {

    override val collectionName = "places"

    suspend fun getAllPlaces(): List<Place> {
        Napier.d(tag = "PlacesRepository") { "getAllPlaces() - Fetching places from local database" }
        return withDatabase {
            val result = queries.selectAllPlaces().executeAsList().map(::mapToPlace)
            Napier.d(tag = "PlacesRepository") { "getAllPlaces() - Found ${result.size} places in database" }
            result
        }
    }

    suspend fun getPlaceById(id: Long): Place? = withDatabase {
        queries.selectPlaceById(id).executeAsOneOrNull()?.let(::mapToPlace)
    }

    suspend fun insertPlaces(places: List<Place>) = withDatabase {
        Napier.d(tag = "PlacesRepository") { "insertPlaces() - Inserting ${places.size} places into database" }
        queries.transaction {
            places.forEach { place ->
                val dbPlace = place.toDbPlace()
                queries.insertPlace(
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
        }
        Napier.d(tag = "PlacesRepository") { "insertPlaces() - Insert complete" }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        Napier.d(tag = "PlacesRepository") { "syncFromFirestore() - Starting places sync from Firestore" }
        return syncFromFirestoreWithIds(
            deserializer = FirestorePlace.serializer(),
            injectId = { documentId, firestorePlace ->
                Place.fromFirestoreData(documentId, firestorePlace)
            },
            insertItems = ::insertPlaces
        )
    }

    private fun mapToPlace(dbPlace: cz.krutsche.xcamp.shared.db.Place): Place {
        Napier.d(tag = "PlacesRepository") { "mapToPlace() - dbPlace.uid=${dbPlace.uid}, dbPlace.name=${dbPlace.name}" }
        return cz.krutsche.xcamp.shared.domain.model.Place(
            id = dbPlace.uid,  // Use uid as id for domain model
            name = dbPlace.name,
            description = dbPlace.description,
            priority = dbPlace.priority,
            latitude = dbPlace.latitude,
            longitude = dbPlace.longitude,
            image = dbPlace.image,
            imageUrl = dbPlace.imageUrl
        )
    }
}
