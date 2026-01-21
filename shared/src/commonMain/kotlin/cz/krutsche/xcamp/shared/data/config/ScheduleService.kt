@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType

class ScheduleService {
    private val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }
    private val repository: ScheduleRepository by lazy {
        ScheduleRepository(
            databaseManager = databaseManager,
            firestoreService = ServiceFactory.getFirestoreService()
        )
    }

    suspend fun getAllSections(): List<Section> {
        return repository.getAllSections()
    }

    suspend fun getSectionById(id: Long): Section? {
        return repository.getSectionById(id)
    }

    suspend fun getSectionsByType(type: SectionType): List<Section> {
        return repository.getSectionsByType(type)
    }

    suspend fun getFavoriteSections(): List<Section> {
        return repository.getFavoriteSections()
    }

    suspend fun getSectionsByDateRange(startTime: kotlin.time.Instant, endTime: kotlin.time.Instant): List<Section> {
        return repository.getSectionsByDateRange(startTime, endTime)
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return repository.syncFromFirestore()
    }

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

    suspend fun toggleFavorite(sectionId: Long, favorite: Boolean): Result<Unit> {
        return try {
            repository.toggleFavorite(sectionId, favorite)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
