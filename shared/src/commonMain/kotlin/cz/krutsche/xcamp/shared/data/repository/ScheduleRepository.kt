@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import kotlin.time.Instant
import kotlinx.serialization.json.Json
import cz.krutsche.xcamp.shared.db.XcampDatabase
import cz.krutsche.xcamp.shared.db.XcampDatabaseQueries
import cz.krutsche.xcamp.shared.db.Section as DbSection
import kotlin.time.Duration.Companion.seconds

// Extension functions to map between database and domain models
private fun DbSection.toDomain(json: Json): Section = Section(
    id = id,
    uid = uid,
    name = name,
    description = description,
    startTime = Instant.fromEpochMilliseconds(startTime),
    endTime = Instant.fromEpochMilliseconds(endTime),
    place = place,
    speakers = speakers?.let { json.decodeFromString<List<Long>>(it) },
    leader = leader,
    type = SectionType.valueOf(type),
    favorite = favorite > 0,
    repeatedDates = repeatedDates?.let { json.decodeFromString<List<String>>(it) }
)

private fun Section.toDbInsert(
    queries: XcampDatabaseQueries,
    json: Json
) {
    queries.insertSection(
        id = id,
        uid = uid,
        name = name,
        description = description,
        startTime = startTime.toEpochMilliseconds(),
        endTime = endTime.toEpochMilliseconds(),
        place = place,
        speakers = speakers?.let { json.encodeToString(it) },
        leader = leader,
        type = type.name,
        favorite = if (favorite) 1 else 0,
        repeatedDates = repeatedDates?.let { json.encodeToString(it) }
    )
}

class ScheduleRepository(
    private val databaseManager: DatabaseManager,
    private val firestoreService: FirestoreService
) {
    private val queries = databaseManager.queries
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun getAllSections(): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectAllSections().executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getSectionById(id: Long): Section? {
        return withContext(Dispatchers.Default) {
            queries.selectSectionById(id).executeAsOneOrNull()?.let { it.toDomain(json) }
        }
    }

    suspend fun getSectionsByType(type: SectionType): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectSectionsByType(type.name).executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getFavoriteSections(): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectFavoriteSections().executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getSectionsByDateRange(startTime: Instant, endTime: Instant): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectSectionsByDateRange(
                startTime.toEpochMilliseconds(),
                endTime.toEpochMilliseconds()
            ).executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun toggleFavorite(sectionId: Long, favorite: Boolean) {
        withContext(Dispatchers.Default) {
            queries.updateSectionFavorite(if (favorite) 1 else 0, sectionId)
        }
    }

    suspend fun insertSection(section: Section) {
        withContext(Dispatchers.Default) {
            section.toDbInsert(queries, json)
        }
    }

    suspend fun insertSections(sections: List<Section>) {
        withContext(Dispatchers.Default) {
            queries.transaction {
                sections.forEach { section ->
                    section.toDbInsert(queries, json)
                }
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return try {
            withTimeout(5.seconds) {
                val result = firestoreService.getCollection("schedule", Section.serializer())
                result.fold(
                    onSuccess = { sections ->
                        val favoriteIds = withContext(Dispatchers.Default) {
                            val ids = queries.selectFavoriteSections()
                                .executeAsList()
                                .map { it.id }
                                .toSet()
                            queries.deleteAllSections()
                            ids
                        }
                        insertSections(sections)
                        if (favoriteIds.isNotEmpty()) {
                            withContext(Dispatchers.Default) {
                                queries.transaction {
                                    favoriteIds.forEach { id ->
                                        queries.updateSectionFavorite(1, id)
                                    }
                                }
                            }
                        }
                        Result.success(Unit)
                    },
                    onFailure = { error ->
                        Result.failure(error)
                    }
                )
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun clearAllSections() {
        withContext(Dispatchers.Default) {
            queries.deleteAllSections()
        }
    }
}