package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.FirestoreSpeaker
import cz.krutsche.xcamp.shared.domain.model.Speaker
import cz.krutsche.xcamp.shared.domain.model.populateImageUrls
import cz.krutsche.xcamp.shared.domain.model.toDbSpeaker
import io.github.aakira.napier.Napier

class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService,
    private val storageService: StorageService
) : BaseRepository<Speaker>(databaseManager, firestoreService) {

    override val collectionName = "speakers"

    suspend fun getAllSpeakers(): List<Speaker> {
        Napier.d(tag = "SpeakersRepository") { "getAllSpeakers() - Fetching speakers from local database" }
        return withDatabase {
            val result = queries.selectAllSpeakers().executeAsList().map(::mapToSpeaker)
            Napier.d(tag = "SpeakersRepository") { "getAllSpeakers() - Found ${result.size} speakers in database" }
            result
        }
    }

    suspend fun getSpeakerById(id: Long): Speaker? = withDatabase {
        queries.selectSpeakerById(id).executeAsOneOrNull()?.let(::mapToSpeaker)
    }

    suspend fun insertSpeakers(speakers: List<Speaker>) = withDatabase {
        Napier.d(tag = "SpeakersRepository") { "insertSpeakers() - Inserting ${speakers.size} speakers into database" }
        queries.transaction {
            speakers.forEach { speaker ->
                val dbSpeaker = speaker.toDbSpeaker()
                queries.insertSpeaker(
                    id = dbSpeaker.id,
                    uid = dbSpeaker.uid,
                    name = dbSpeaker.name,
                    description = dbSpeaker.description,
                    priority = dbSpeaker.priority,
                    image = dbSpeaker.image,
                    imageUrl = dbSpeaker.imageUrl
                )
            }
        }
        Napier.d(tag = "SpeakersRepository") { "insertSpeakers() - Insert complete" }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        Napier.d(tag = "SpeakersRepository") { "syncFromFirestore() - Starting speakers sync from Firestore with document ID injection" }
        return syncFromFirestoreWithIds(
            deserializer = FirestoreSpeaker.serializer(),
            injectId = { documentId, firestoreSpeaker ->
                Speaker.fromFirestoreData(documentId, firestoreSpeaker)
            },
            insertItems = { speakers ->
                // Populate imageUrls for speakers with images using shared extension
                val speakersWithUrls = speakers.populateImageUrls(
                    storageService = storageService,
                    entityName = "speaker",
                    copyWithUrl = { imageUrl -> this.copy(imageUrl = imageUrl) }
                )
                insertSpeakers(speakersWithUrls)
            }
        )
    }

    private fun mapToSpeaker(dbSpeaker: cz.krutsche.xcamp.shared.db.Speaker): Speaker =
        cz.krutsche.xcamp.shared.domain.model.Speaker(
            id = dbSpeaker.uid,  // Use uid as id for domain model
            name = dbSpeaker.name,
            description = dbSpeaker.description,
            priority = dbSpeaker.priority,
            image = dbSpeaker.image,
            imageUrl = dbSpeaker.imageUrl
        )
}
