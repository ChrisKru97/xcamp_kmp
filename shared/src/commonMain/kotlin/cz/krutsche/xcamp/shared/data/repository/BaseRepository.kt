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
        insertItems: suspend (List<T>) -> Unit
    ): Result<Unit> {
        val tag = "BaseRepository[$collectionName]"
        Napier.d(tag = tag) { "syncFromFirestoreWithIds() - Starting sync from Firestore collection '$collectionName' with document ID injection" }
        return try {
            val result = firestoreService.getCollectionWithIds(collectionName, deserializer)
            result.fold(
                onSuccess = { itemsWithIds ->
                    val items = itemsWithIds.map { (documentId, item) ->
                        injectId(documentId, item)
                    }
                    Napier.i(tag = tag) { "syncFromFirestoreWithIds() - Successfully fetched ${items.size} items from Firestore with document IDs" }
                    insertItems(items)
                    Napier.i(tag = tag) { "syncFromFirestoreWithIds() - Successfully inserted ${items.size} items into database" }
                    Result.success(Unit)
                },
                onFailure = { error ->
                    Napier.e(tag = tag, throwable = error) { "syncFromFirestoreWithIds() - Failed to fetch from Firestore: ${error.message}" }
                    Result.failure(error)
                }
            )
        } catch (e: Exception) {
            Napier.e(tag = tag, throwable = e) { "syncFromFirestoreWithIds() - Exception during sync: ${e.message}" }
            Result.failure(e)
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
