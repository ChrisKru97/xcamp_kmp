package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.firebase.Analytics
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsEvents
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.local.EntityType
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
        val hasCached = databaseManager.hasCachedData(entityType)
        logCacheHit(hit = hasCached)
        return hasCached
    }

    protected fun logCacheHit(hit: Boolean) {
        Analytics.logEvent(
            name = AnalyticsEvents.CACHE_HIT,
            parameters = mapOf(
                AnalyticsEvents.PARAM_ENTITY_TYPE to entityType.collectionName,
                AnalyticsEvents.PARAM_HIT to hit.toString()
            )
        )
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
        val startTime = now().toEpochMilliseconds()
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

                    val durationMs = currentTime - startTime
                    logDataSync(success = true, durationMs = durationMs)

                    Result.success(Unit)
                },
                onFailure = { error ->
                    val durationMs = now().toEpochMilliseconds() - startTime
                    logDataSync(success = false, durationMs = durationMs)
                    Result.failure(NetworkError)
                }
            )
        } catch (e: Exception) {
            val durationMs = now().toEpochMilliseconds() - startTime
            logDataSync(success = false, durationMs = durationMs)
            logRepositoryError(e, "syncFromFirestore")
            Result.failure(NetworkError)
        }
    }

    private fun logDataSync(success: Boolean, durationMs: Long) {
        Analytics.logEvent(
            name = AnalyticsEvents.DATA_SYNC,
            parameters = mapOf(
                AnalyticsEvents.PARAM_ENTITY_TYPE to entityType.collectionName,
                AnalyticsEvents.SUCCESS to success.toString(),
                AnalyticsEvents.PARAM_DURATION_MS to durationMs.toString()
            )
        )
    }

    protected fun logRepositoryError(throwable: Throwable, operation: String) {
        CrashlyticsService.logNonFatalError(throwable)
        CrashlyticsService.setCustomKey("repo_operation", operation)
        CrashlyticsService.setCustomKey("entity_type", entityType.collectionName)
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
