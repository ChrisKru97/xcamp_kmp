package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.FirestoreSpeaker
import cz.krutsche.xcamp.shared.domain.model.Speaker
import cz.krutsche.xcamp.shared.domain.model.toDbSpeaker
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService,
    private val storageService: StorageService
) : BaseRepository<Speaker>(databaseManager, firestoreService) {

    private val syncMutex = Mutex()

    override val collectionName = "speakers"

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

    suspend fun syncFromFirestore(): Result<Unit> = syncMutex.withLock {
        syncFromFirestoreWithIds(
            deserializer = FirestoreSpeaker.serializer(),
            injectId = { documentId, firestoreSpeaker ->
                Speaker.fromFirestoreData(documentId, firestoreSpeaker)
            },
            insertItems = { speakers ->
                val speakersWithUrls = withTimeout(30.seconds) {
                    coroutineScope {
                        speakers.map { speaker ->
                            async {
                                if (speaker.image != null) {
                                    val urlResult = storageService.getDownloadUrl(speaker.image)
                                    speaker.copy(imageUrl = urlResult.getOrNull())
                                } else {
                                    speaker
                                }
                            }
                        }.awaitAll()
                    }
                }
                withDatabase {
                    queries.transaction {
                        queries.deleteAllSpeakers()
                        speakersWithUrls.forEach { speaker ->
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
            },
            validateItems = { speakers ->
                if (speakers.isEmpty()) {
                    Result.failure(SyncError.ValidationError("No speakers received from Firestore"))
                } else {
                    Result.success(Unit)
                }
            }
        )
    }

    private fun mapToSpeaker(dbSpeaker: cz.krutsche.xcamp.shared.db.Speaker): Speaker =
        cz.krutsche.xcamp.shared.domain.model.Speaker(
            uid = dbSpeaker.uid,
            name = dbSpeaker.name,
            description = dbSpeaker.description,
            priority = dbSpeaker.priority,
            image = dbSpeaker.image,
            imageUrl = dbSpeaker.imageUrl
        )
}
