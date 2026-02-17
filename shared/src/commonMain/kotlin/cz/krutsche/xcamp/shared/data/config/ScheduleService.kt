package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.ExpandedSection
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType

class ScheduleService : RepositoryService<ScheduleRepository>() {
    override fun createRepository(): ScheduleRepository {
        return ScheduleRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService()
        )
    }

    suspend fun getAllSections(): List<Section> {
        return repository.getAllSections()
    }

    suspend fun getSectionById(uid: String): Section? {
        return repository.getSectionById(uid)
    }

    suspend fun getFavoriteSections(): List<Section> {
        return repository.getFavoriteSections()
    }

    suspend fun getExpandedSections(dayNumber: Int, startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return repository.getExpandedSections(dayNumber, startDate)
    }

    suspend fun getAllExpandedSections(startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return repository.getAllExpandedSections(startDate)
    }

    suspend fun getExpandedSectionsByTypesAndFavorite(
        dayNumber: Int,
        types: Set<SectionType>,
        favoritesOnly: Boolean,
        startDate: String = DEFAULT_START_DATE
    ): List<ExpandedSection> {
        return repository.getExpandedSectionsByTypesAndFavorite(dayNumber, types, favoritesOnly, startDate)
    }

    suspend fun getSectionsByTypesAndFavorite(
        types: Set<SectionType>,
        favoritesOnly: Boolean
    ): List<Section> {
        return repository.getSectionsByTypesAndFavorite(types, favoritesOnly)
    }

    override suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

    suspend fun refreshSections(): Result<List<Section>> {
        val syncResult = syncFromFirestore()
        return syncResult.fold(
            onSuccess = { Result.success(getAllSections()) },
            onFailure = { Result.failure(it) }
        )
    }

    suspend fun refreshSectionsWithFallback(): Result<List<Section>> {
        val syncResult = syncFromFirestore()
        val sections = getAllSections()

        return syncResult.fold(
            onSuccess = { Result.success(sections) },
            onFailure = { error ->
                if (sections.isNotEmpty()) {
                    Result.success(sections)
                } else {
                    Result.failure(error)
                }
            }
        )
    }

    suspend fun toggleFavorite(sectionUid: String, favorite: Boolean): Result<Unit> {
        return try {
            repository.toggleFavorite(sectionUid, favorite)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
