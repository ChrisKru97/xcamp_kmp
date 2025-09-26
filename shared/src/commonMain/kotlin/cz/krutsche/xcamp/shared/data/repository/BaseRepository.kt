package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
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
        return try {
            firestoreService.getCollection(collectionName, deserializer)
                .fold(
                    onSuccess = { items ->
                        insertItems(items)
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