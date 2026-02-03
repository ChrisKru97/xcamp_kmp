package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.consts.StoragePaths
import cz.krutsche.xcamp.shared.domain.model.FirestorePlace
import cz.krutsche.xcamp.shared.domain.model.Place
import cz.krutsche.xcamp.shared.domain.model.toDbPlace

class PlacesRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService,
    private val storageService: StorageService
) : BaseRepository<Place>(databaseManager, firestoreService) {

    override val collectionName = "places"

    suspend fun getAllPlaces(): List<Place> {
        return withDatabase {
            queries.selectAllPlaces().executeAsList().map(::mapToPlace)
        }
    }

    suspend fun getPlaceById(uid: String): Place? = withDatabase {
        queries.selectPlaceById(uid).executeAsOneOrNull()?.let(::mapToPlace)
    }

    suspend fun insertPlaces(places: List<Place>) = withDatabase {
        queries.transaction {
            places.forEach { place ->
                val dbPlace = place.toDbPlace()
                queries.insertPlace(
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
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return syncFromFirestoreWithIds(
            deserializer = FirestorePlace.serializer(),
            injectId = { documentId, firestorePlace ->
                Place.fromFirestoreData(documentId, firestorePlace)
            },
            insertItems = { places ->
                val placesWithUrls = places.map { place ->
                    if (place.image != null) {
                        val urlResult = storageService.getDownloadUrl(place.image)
                        place.copy(imageUrl = urlResult.getOrNull())
                    } else {
                        place
                    }
                }
                insertPlaces(placesWithUrls)
            },
            clearItems = { withDatabase { queries.deleteAllPlaces() } }
        )
    }

    private fun mapToPlace(dbPlace: cz.krutsche.xcamp.shared.db.Place): Place {
        return cz.krutsche.xcamp.shared.domain.model.Place(
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

    suspend fun getArealImageURL(): String? {
        return storageService.getDownloadUrl(StoragePaths.AREAL_MAP)
            .getOrNull()
    }
}
