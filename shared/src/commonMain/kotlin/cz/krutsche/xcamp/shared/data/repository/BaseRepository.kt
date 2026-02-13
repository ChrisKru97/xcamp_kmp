@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.local.EntityType
import cz.krutsche.xcamp.shared.localization.Strings
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.DeserializationStrategy
import kotlin.time.Clock.System.now

abstract class BaseRepository<T : Any>(
    protected val databaseManager: DatabaseManager,
    protected val firestoreService: FirestoreService
) {
    protected val queries = databaseManager.queries
    abstract val entityType: EntityType
    protected abstract val syncMutex: Mutex

    protected suspend fun <R> withDatabase(block: suspend () -> R): R {
        return withContext(Dispatchers.Default) {
            block()
        }
    }

    internal suspend fun hasCachedData(): Boolean {
        return databaseManager.hasCachedData(entityType)
    }

    protected suspend fun getLastSyncTime(): Long? {
        return databaseManager.getLastSyncTime(entityType)
    }

    protected suspend fun updateSyncMetadata(syncTime: Long, version: Long = 1L) {
        databaseManager.updateSyncMetadata(entityType, syncTime, version)
    }

    internal suspend fun isDataStale(maxAgeMs: Long = DEFAULT_STALENESS_MS): Boolean {
        val lastSync = getLastSyncTime() ?: return true
        val currentTime = now().toEpochMilliseconds()
        return (currentTime - lastSync) > maxAgeMs
    }

    private suspend fun <F : Any> syncFromFirestore(
        deserializer: DeserializationStrategy<F>,
        injectId: ((documentId: String, item: F) -> T)? = null,
        insertItems: suspend (List<T>) -> Unit,
        validateItems: (suspend (List<T>) -> Result<Unit>)? = null
    ): Result<Unit> {
        return try {
            val result = firestoreService.getCollectionWithIds(entityType.collectionName, deserializer)
            result.fold(
                onSuccess = { itemsWithIds ->
                    val items = itemsWithIds.map { (documentId, item) ->
                        injectId?.invoke(documentId, item) ?: item as T
                    }

                    validateItems?.invoke(items)?.fold(
                        onSuccess = { },
                        onFailure = { error -> return Result.failure(error) }
                    )

                    insertItems(items)

                    val currentTime = now().toEpochMilliseconds()
                    updateSyncMetadata(currentTime)
                    Result.success(Unit)
                },
                onFailure = { error ->
                    Result.failure(NetworkError)
                }
            )
        } catch (e: Exception) {
            Result.failure(NetworkError)
        }
    }

    protected suspend fun <F : Any> syncFromFirestoreLocked(
        deserializer: DeserializationStrategy<F>,
        injectId: ((documentId: String, item: F) -> T)? = null,
        insertItems: suspend (List<T>) -> Unit,
        validateItems: (suspend (List<T>) -> Result<Unit>)? = null
    ): Result<Unit> = syncMutex.withLock {
        syncFromFirestore(deserializer, injectId, insertItems, validateItems)
    }
}
