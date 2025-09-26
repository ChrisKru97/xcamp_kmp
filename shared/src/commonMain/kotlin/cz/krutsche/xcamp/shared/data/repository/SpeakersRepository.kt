package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Speaker

class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Speaker>(databaseManager, firestoreService) {

    override val collectionName = "speakers"

    suspend fun getAllSpeakers(): List<Speaker> = withDatabase {
        queries.selectAllSpeakers().executeAsList().map(::mapToSpeaker)
    }

    suspend fun getSpeakerById(id: Long): Speaker? = withDatabase {
        queries.selectSpeakerById(id).executeAsOneOrNull()?.let(::mapToSpeaker)
    }

    suspend fun insertSpeakers(speakers: List<Speaker>) = withDatabase {
        queries.transaction {
            speakers.forEach { speaker ->
                queries.insertSpeaker(
                    id = speaker.id,
                    uid = speaker.uid,
                    name = speaker.name,
                    description = speaker.description,
                    priority = speaker.priority,
                    image = speaker.image,
                    imageUrl = speaker.imageUrl
                )
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> =
        syncFromFirestore(Speaker.serializer(), ::insertSpeakers)

    private fun mapToSpeaker(dbSpeaker: cz.krutsche.xcamp.shared.db.Speaker): Speaker =
        cz.krutsche.xcamp.shared.domain.model.Speaker(
            id = dbSpeaker.id,
            uid = dbSpeaker.uid,
            name = dbSpeaker.name,
            description = dbSpeaker.description,
            priority = dbSpeaker.priority,
            image = dbSpeaker.image,
            imageUrl = dbSpeaker.imageUrl
        )
}