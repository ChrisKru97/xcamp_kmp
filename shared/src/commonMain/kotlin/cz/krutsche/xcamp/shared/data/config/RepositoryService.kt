package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.local.DatabaseManager

/**
 * Base class for services that wrap repositories with lazy initialization.
 * Provides common database manager initialization and repository creation pattern.
 *
 * @param R The repository type this service manages
 */
abstract class RepositoryService<R : Any> {
    /**
     * Lazy-initialized database manager shared across all repository services.
     */
    protected val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }

    /**
     * Factory method to create the repository instance.
     * Subclasses must implement this to provide their specific repository.
     */
    protected abstract fun createRepository(): R

    /**
     * Lazy-initialized repository instance created by [createRepository].
     */
    protected val repository: R by lazy { createRepository() }

    /**
     * Sync data from Firestore to local database.
     * Delegates to the repository's syncFromFirestore method.
     */
    protected abstract suspend fun syncFromFirestore(): Result<Unit>

    /**
     * Generic refresh pattern: sync from Firestore and return all items.
     * Subclasses can override this if they need custom behavior.
     */
    protected open suspend fun refresh(): Result<Unit> {
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = { Result.success(Unit) },
                onFailure = { Result.failure(it) }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
