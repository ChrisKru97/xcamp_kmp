package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Speaker
import io.github.aakira.napier.Napier

class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
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
        Napier.d(tag = "SpeakersRepository") { "insertSpeakers() - Insert complete" }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        Napier.d(tag = "SpeakersRepository") { "syncFromFirestore() - Starting speakers sync from Firestore" }
        return syncFromFirestore(Speaker.serializer(), ::insertSpeakers)
    }

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
