@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType

/**
 * Service for managing Section (schedule) entities.
 *
 * Provides access to schedule/section data from both local database and remote Firestore.
 * Extends [RepositoryService] for common repository initialization and sync functionality.
 * Uses [kotlin.time.Instant] for time-based queries (experimental API).
 *
 * @property repository The lazily initialized ScheduleRepository instance
 */
class ScheduleService : RepositoryService<ScheduleRepository>() {
    /**
     * Creates a new ScheduleRepository instance.
     *
     * @return A new ScheduleRepository with all required dependencies injected
     */
    override fun createRepository(): ScheduleRepository {
        return ScheduleRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService()
        )
    }

    /**
     * Retrieves all sections from the local database.
     *
     * @return List of all sections, empty list if none exist
     */
    suspend fun getAllSections(): List<Section> {
        return repository.getAllSections()
    }

    /**
     * Retrieves a specific section by its numeric ID.
     *
     * @param id The numeric ID of the section (generated from document ID)
     * @return The section if found, null otherwise
     */
    suspend fun getSectionById(id: Long): Section? {
        return repository.getSectionById(id)
    }

    /**
     * Retrieves sections filtered by type.
     *
     * @param type The section type to filter by (main, internal, gospel, food, other)
     * @return List of sections matching the specified type
     */
    suspend fun getSectionsByType(type: SectionType): List<Section> {
        return repository.getSectionsByType(type)
    }

    /**
     * Retrieves all favorited sections.
     *
     * @return List of sections marked as favorites
     */
    suspend fun getFavoriteSections(): List<Section> {
        return repository.getFavoriteSections()
    }

    /**
     * Retrieves sections within a specific date/time range.
     *
     * @param startTime Start of the time range (inclusive)
     * @param endTime End of the time range (inclusive)
     * @return List of sections that fall within the specified time range
     */
    suspend fun getSectionsByDateRange(startTime: kotlin.time.Instant, endTime: kotlin.time.Instant): List<Section> {
        return repository.getSectionsByDateRange(startTime, endTime)
    }

    /**
     * Synchronizes section data from Firestore to the local database.
     *
     * @return Result.Success on success, Result.Failure on error
     */
    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    /**
     * Refreshes sections from Firestore and returns the updated list.
     *
     * Performs a sync from Firestore and returns all sections from the local database.
     *
     * @return Result.Success containing the list of sections, or Result.Failure on error
     */
    suspend fun refreshSections(): Result<List<Section>> {
        return try {
            val syncResult = syncFromFirestore()
            syncResult.fold(
                onSuccess = { Result.success(getAllSections()) },
                onFailure = { Result.failure(it) }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Toggles the favorite status of a section.
     *
     * Updates the favorite flag for a specific section in the local database.
     *
     * @param sectionId The numeric ID of the section
     * @param favorite The new favorite status (true to favorite, false to unfavorite)
     * @return Result.Success on success, Result.Failure on error
     */
    suspend fun toggleFavorite(sectionId: Long, favorite: Boolean): Result<Unit> {
        return try {
            repository.toggleFavorite(sectionId, favorite)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
