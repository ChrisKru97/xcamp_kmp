package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.local.EntityType
import cz.krutsche.xcamp.shared.domain.model.FirestoreSpeaker
import cz.krutsche.xcamp.shared.domain.model.Speaker
import cz.krutsche.xcamp.shared.domain.model.toDbSpeaker
import kotlinx.coroutines.sync.Mutex

class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService,
    private val storageService: StorageService
) : BaseRepository<Speaker>(databaseManager, firestoreService) {

    override val entityType = EntityType.SPEAKERS
    override val syncMutex = Mutex()

    suspend fun getAllSpeakers(): List<Speaker> {
        return withDatabase {
            queries.selectAllSpeakers().executeAsList().map(::mapToSpeaker)
        }
    }

    suspend fun getSpeakerById(uid: String): Speaker? = withDatabase {
        queries.selectSpeakerById(uid).executeAsOneOrNull()?.let(::mapToSpeaker)
    }

    suspend fun insertSpeakers(speakers: List<Speaker>) = withDatabase {
        queries.transaction {
            speakers.forEach { speaker ->
                val dbSpeaker = speaker.toDbSpeaker()
                queries.insertSpeaker(
                    uid = dbSpeaker.uid,
                    name = dbSpeaker.name,
                    description = dbSpeaker.description,
                    priority = dbSpeaker.priority,
                    image = dbSpeaker.image,
                    imageUrl = dbSpeaker.imageUrl
                )
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> = syncFromFirestoreLocked(
        deserializer = FirestoreSpeaker.serializer(),
        injectId = { documentId, firestoreSpeaker ->
            Speaker.fromFirestoreData(documentId, firestoreSpeaker)
        },
        insertItems = { speakers ->
            insertSpeakers(speakers)
        },
        validateItems = { speakers ->
            if (speakers.isEmpty()) {
                Result.failure(ValidationError)
            } else {
                Result.success(Unit)
            }
        }
    )

    private fun mapToSpeaker(dbSpeaker: cz.krutsche.xcamp.shared.db.Speaker): Speaker =
        cz.krutsche.xcamp.shared.domain.model.Speaker(
            uid = dbSpeaker.uid,
            name = dbSpeaker.name,
            description = dbSpeaker.description,
            priority = dbSpeaker.priority,
            image = dbSpeaker.image
        )
}
