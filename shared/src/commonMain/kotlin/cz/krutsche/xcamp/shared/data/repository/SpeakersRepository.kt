package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Speaker
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class SpeakersRepository(
    private val databaseManager: DatabaseManager,
    private val firestoreService: FirestoreService
) {
    private val queries = databaseManager.queries

    suspend fun getAllSpeakers(): List<Speaker> {
        return withContext(Dispatchers.Default) {
            queries.selectAllSpeakers().executeAsList().map { dbSpeaker ->
                Speaker(
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
    }

    suspend fun getSpeakerById(id: Long): Speaker? {
        return withContext(Dispatchers.Default) {
            queries.selectSpeakerById(id).executeAsOneOrNull()?.let { dbSpeaker ->
                Speaker(
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
    }

    suspend fun insertSpeakers(speakers: List<Speaker>) {
        withContext(Dispatchers.Default) {
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
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return try {
            val result = firestoreService.getCollection("speakers", Speaker.serializer())
            result.fold(
                onSuccess = { speakers ->
                    insertSpeakers(speakers)
                    Result.success(Unit)
                },
                onFailure = { error ->
                    Result.failure(error)
                }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}