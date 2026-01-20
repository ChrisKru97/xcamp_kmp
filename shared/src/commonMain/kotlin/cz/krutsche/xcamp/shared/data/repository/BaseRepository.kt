package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import io.github.aakira.napier.Napier
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.DeserializationStrategy

abstract class BaseRepository<T : Any>(
    protected val databaseManager: DatabaseManager,
    protected val firestoreService: FirestoreService
) {
    protected val queries = databaseManager.queries

    abstract val collectionName: String

    protected suspend fun <R> withDatabase(block: suspend () -> R): R {
        return withContext(Dispatchers.Default) {
            block()
        }
    }

    suspend fun syncFromFirestore(
        deserializer: DeserializationStrategy<T>,
        insertItems: suspend (List<T>) -> Unit
    ): Result<Unit> {
        val tag = "BaseRepository[$collectionName]"
        Napier.d(tag = tag) { "syncFromFirestore() - Starting sync from Firestore collection '$collectionName'" }
        return try {
            val result = firestoreService.getCollection(collectionName, deserializer)
            result.fold(
                onSuccess = { items ->
                    Napier.i(tag = tag) { "syncFromFirestore() - Successfully fetched ${items.size} items from Firestore" }
                    insertItems(items)
                    Napier.i(tag = tag) { "syncFromFirestore() - Successfully inserted ${items.size} items into database" }
                    Result.success(Unit)
                },
                onFailure = { error ->
                    Napier.e(tag = tag, throwable = error) { "syncFromFirestore() - Failed to fetch from Firestore: ${error.message}" }
                    Result.failure(error)
                }
            )
        } catch (e: Exception) {
            Napier.e(tag = tag, throwable = e) { "syncFromFirestore() - Exception during sync: ${e.message}" }
            Result.failure(e)
        }
    }
}
