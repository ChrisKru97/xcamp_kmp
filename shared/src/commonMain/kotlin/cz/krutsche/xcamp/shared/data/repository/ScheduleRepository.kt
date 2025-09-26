@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Instant
import kotlinx.serialization.json.Json

class ScheduleRepository(
    private val databaseManager: DatabaseManager,
    private val firestoreService: FirestoreService
) {
    private val queries = databaseManager.queries
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun getAllSections(): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectAllSections().executeAsList().map { dbSection ->
                Section(
                    id = dbSection.id,
                    uid = dbSection.uid,
                    name = dbSection.name,
                    description = dbSection.description,
                    startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                    endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                    place = dbSection.place,
                    speakers = dbSection.speakers?.let {
                        json.decodeFromString<List<Long>>(it)
                    },
                    leader = dbSection.leader,
                    type = SectionType.valueOf(dbSection.type),
                    favorite = dbSection.favorite > 0,
                    repeatedDates = dbSection.repeatedDates?.let {
                        json.decodeFromString<List<String>>(it)
                    }
                )
            }
        }
    }

    suspend fun getSectionById(id: Long): Section? {
        return withContext(Dispatchers.Default) {
            queries.selectSectionById(id).executeAsOneOrNull()?.let { dbSection ->
                Section(
                    id = dbSection.id,
                    uid = dbSection.uid,
                    name = dbSection.name,
                    description = dbSection.description,
                    startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                    endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                    place = dbSection.place,
                    speakers = dbSection.speakers?.let {
                        json.decodeFromString<List<Long>>(it)
                    },
                    leader = dbSection.leader,
                    type = SectionType.valueOf(dbSection.type),
                    favorite = dbSection.favorite > 0,
                    repeatedDates = dbSection.repeatedDates?.let {
                        json.decodeFromString<List<String>>(it)
                    }
                )
            }
        }
    }

    suspend fun getSectionsByType(type: SectionType): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectSectionsByType(type.name).executeAsList().map { dbSection ->
                Section(
                    id = dbSection.id,
                    uid = dbSection.uid,
                    name = dbSection.name,
                    description = dbSection.description,
                    startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                    endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                    place = dbSection.place,
                    speakers = dbSection.speakers?.let {
                        json.decodeFromString<List<Long>>(it)
                    },
                    leader = dbSection.leader,
                    type = SectionType.valueOf(dbSection.type),
                    favorite = dbSection.favorite > 0,
                    repeatedDates = dbSection.repeatedDates?.let {
                        json.decodeFromString<List<String>>(it)
                    }
                )
            }
        }
    }

    suspend fun getFavoriteSections(): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectFavoriteSections().executeAsList().map { dbSection ->
                Section(
                    id = dbSection.id,
                    uid = dbSection.uid,
                    name = dbSection.name,
                    description = dbSection.description,
                    startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                    endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                    place = dbSection.place,
                    speakers = dbSection.speakers?.let {
                        json.decodeFromString<List<Long>>(it)
                    },
                    leader = dbSection.leader,
                    type = SectionType.valueOf(dbSection.type),
                    favorite = dbSection.favorite > 0,
                    repeatedDates = dbSection.repeatedDates?.let {
                        json.decodeFromString<List<String>>(it)
                    }
                )
            }
        }
    }

    suspend fun getSectionsByDateRange(startTime: Instant, endTime: Instant): List<Section> {
        return withContext(Dispatchers.Default) {
            queries.selectSectionsByDateRange(
                startTime.toEpochMilliseconds(),
                endTime.toEpochMilliseconds()
            ).executeAsList().map { dbSection ->
                Section(
                    id = dbSection.id,
                    uid = dbSection.uid,
                    name = dbSection.name,
                    description = dbSection.description,
                    startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                    endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                    place = dbSection.place,
                    speakers = dbSection.speakers?.let {
                        json.decodeFromString<List<Long>>(it)
                    },
                    leader = dbSection.leader,
                    type = SectionType.valueOf(dbSection.type),
                    favorite = dbSection.favorite > 0,
                    repeatedDates = dbSection.repeatedDates?.let {
                        json.decodeFromString<List<String>>(it)
                    }
                )
            }
        }
    }

    suspend fun toggleFavorite(sectionId: Long, favorite: Boolean) {
        withContext(Dispatchers.Default) {
            queries.updateSectionFavorite(if (favorite) 1 else 0, sectionId)
        }
    }

    suspend fun insertSection(section: Section) {
        withContext(Dispatchers.Default) {
            queries.insertSection(
                id = section.id,
                uid = section.uid,
                name = section.name,
                description = section.description,
                startTime = section.startTime.toEpochMilliseconds(),
                endTime = section.endTime.toEpochMilliseconds(),
                place = section.place,
                speakers = section.speakers?.let { json.encodeToString(it) },
                leader = section.leader,
                type = section.type.name,
                favorite = if (section.favorite) 1 else 0,
                repeatedDates = section.repeatedDates?.let { json.encodeToString(it) }
            )
        }
    }

    suspend fun insertSections(sections: List<Section>) {
        withContext(Dispatchers.Default) {
            queries.transaction {
                sections.forEach { section ->
                    queries.insertSection(
                        id = section.id,
                        uid = section.uid,
                        name = section.name,
                        description = section.description,
                        startTime = section.startTime.toEpochMilliseconds(),
                        endTime = section.endTime.toEpochMilliseconds(),
                        place = section.place,
                        speakers = section.speakers?.let { json.encodeToString(it) },
                        leader = section.leader,
                        type = section.type.name,
                        favorite = if (section.favorite) 1 else 0,
                        repeatedDates = section.repeatedDates?.let { json.encodeToString(it) }
                    )
                }
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return try {
            val result = firestoreService.getCollection("schedule", Section.serializer())
            result.fold(
                onSuccess = { sections ->
                    insertSections(sections)
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

    suspend fun clearAllSections() {
        withContext(Dispatchers.Default) {
            queries.deleteAllSections()
        }
    }
}