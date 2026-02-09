@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.ExpandedSection
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType

/**
 * Service for managing Section (schedule) entities.
 *
 * Provides access to schedule/section data from both local database and remote Firestore.
 * Extends [RepositoryService] for common repository initialization and sync functionality.
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
     * Retrieves a specific section by its uid.
     *
     * @param uid The uid of the section (Firebase document ID)
     * @return The section if found, null otherwise
     */
    suspend fun getSectionById(uid: String): Section? {
        return repository.getSectionById(uid)
    }

    /**
     * Retrieves sections filtered by type.
     *
     * @param type The section type to filter by (main, internal, gospel, food)
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
     * Retrieves expanded sections for a specific day.
     *
     * Multi-day sections are expanded into individual entries for display.
     *
     * @param dayNumber The day number (e.g., 21 for July 21)
     * @param startDate The start date in YYYY-MM-DD format (default: 2026-07-18)
     * @return List of expanded sections for the specified day
     */
    suspend fun getExpandedSections(dayNumber: Int, startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return repository.getExpandedSections(dayNumber, startDate)
    }

    /**
     * Retrieves all expanded sections across all days.
     *
     * Multi-day sections are expanded into individual entries for display.
     *
     * @param startDate The start date in YYYY-MM-DD format (default: 2026-07-18)
     * @return List of all expanded sections sorted by start time
     */
    suspend fun getAllExpandedSections(startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return repository.getAllExpandedSections(startDate)
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
     * @param sectionUid The uid of the section
     * @param favorite The new favorite status (true to favorite, false to unfavorite)
     * @return Result.Success on success, Result.Failure on error
     */
    suspend fun toggleFavorite(sectionUid: String, favorite: Boolean): Result<Unit> {
        return try {
            repository.toggleFavorite(sectionUid, favorite)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
