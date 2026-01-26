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

    /**
     * Sync from Firestore with document ID injection.
     * Use this for collections where documents don't have an explicit 'id' field.
     * The documentId parameter allows injecting the Firestore document ID into the domain model.
     *
     * @param F The Firestore data type (without id field)
     * @param deserializer Deserialization strategy for the Firestore data
     * @param injectId Function to inject document ID into domain model
     * @param insertItems Function to insert the converted items into database
     */
    protected suspend fun <F : Any> syncFromFirestoreWithIds(
        deserializer: DeserializationStrategy<F>,
        injectId: (documentId: String, item: F) -> T,
        insertItems: suspend (List<T>) -> Unit,
        clearItems: (suspend () -> Unit)? = null
    ): Result<Unit> {
        return try {
            val result = firestoreService.getCollectionWithIds(collectionName, deserializer)
            result.fold(
                onSuccess = { itemsWithIds ->
                    val items = itemsWithIds.map { (documentId, item) ->
                        injectId(documentId, item)
                    }
                    clearItems?.invoke()
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

    suspend fun syncFromFirestore(
        deserializer: DeserializationStrategy<T>,
        insertItems: suspend (List<T>) -> Unit,
        clearItems: (suspend () -> Unit)? = null
    ): Result<Unit> {
        return try {
            val result = firestoreService.getCollection(collectionName, deserializer)
            result.fold(
                onSuccess = { items ->
                    clearItems?.invoke()
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
