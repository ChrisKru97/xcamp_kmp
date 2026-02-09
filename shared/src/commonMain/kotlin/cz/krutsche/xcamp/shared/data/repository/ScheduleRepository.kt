@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import cz.krutsche.xcamp.shared.data.config.DEFAULT_START_DATE
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.domain.model.ExpandedSection
import cz.krutsche.xcamp.shared.domain.model.FirestoreSection
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.domain.model.SectionType
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import cz.krutsche.xcamp.shared.db.XcampDatabaseQueries
import cz.krutsche.xcamp.shared.db.Section as DbSection
import kotlin.time.Duration.Companion.seconds

private fun DbSection.toDomain(json: Json): Section = Section(
    uid = uid,
    name = name,
    description = description,
    days = json.decodeFromString<List<Int>>(days),
    startTime = startTime,
    endTime = endTime,
    place = place,
    speakers = speakers?.let { json.decodeFromString<List<String>>(it) },
    leader = leader,
    type = SectionType.valueOf(type),
    favorite = favorite > 0
)

private fun Section.toDbInsert(
    queries: XcampDatabaseQueries,
    json: Json
) {
    queries.insertSection(
        uid = uid,
        name = name,
        description = description,
        days = json.encodeToString(days),
        startTime = startTime,
        endTime = endTime,
        place = place,
        speakers = speakers?.let { json.encodeToString(it) },
        leader = leader,
        type = type.name,
        favorite = if (favorite) 1 else 0
    )
}

class ScheduleRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Section>(databaseManager, firestoreService) {

    override val collectionName = "schedule"

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun getAllSections(): List<Section> {
        return withDatabase {
            queries.selectAllSections().executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getSectionById(uid: String): Section? {
        return withDatabase {
            queries.selectSectionById(uid).executeAsOneOrNull()?.let { it.toDomain(json) }
        }
    }

    suspend fun getSectionsByType(type: SectionType): List<Section> {
        return withDatabase {
            queries.selectSectionsByType(type.name).executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getFavoriteSections(): List<Section> {
        return withDatabase {
            queries.selectFavoriteSections().executeAsList().map { it.toDomain(json) }
        }
    }

    suspend fun getExpandedSections(dayNumber: Int, startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return withDatabase {
            getAllSections()
                .flatMap { section ->
                    if (dayNumber in section.days) {
                        section.expand(startDate).filter { it.day == dayNumber }
                    } else {
                        emptyList()
                    }
                }
                .sortedBy { it.startTime }
        }
    }

    suspend fun getAllExpandedSections(startDate: String = DEFAULT_START_DATE): List<ExpandedSection> {
        return withDatabase {
            getAllSections()
                .flatMap { it.expand(startDate) }
                .sortedBy { it.startTime }
        }
    }

    suspend fun toggleFavorite(sectionUid: String, favorite: Boolean) {
        withDatabase {
            queries.updateSectionFavorite(if (favorite) 1 else 0, sectionUid)
        }
    }

    suspend fun insertSection(section: Section) {
        withDatabase {
            section.toDbInsert(queries, json)
        }
    }

    suspend fun insertSections(sections: List<Section>) {
        withDatabase {
            queries.transaction {
                sections.forEach { section ->
                    section.toDbInsert(queries, json)
                }
            }
        }
    }

    suspend fun syncFromFirestore(): Result<Unit> {
        return syncFromFirestoreWithIds(
            deserializer = FirestoreSection.serializer(),
            injectId = { documentId, firestoreSection ->
                Section.fromFirestoreData(documentId, firestoreSection)
            },
            insertItems = { sections -> insertSections(sections) },
            clearItems = {
                val favoriteUids = withDatabase {
                    val uids = queries.selectFavoriteSections()
                        .executeAsList()
                        .map { it.uid }
                        .toSet()
                    queries.deleteAllSections()
                    uids
                }
                if (favoriteUids.isNotEmpty()) {
                    withDatabase {
                        queries.transaction {
                            favoriteUids.forEach { uid ->
                                queries.updateSectionFavorite(1, uid)
                            }
                        }
                    }
                }
            }
        )
    }

    suspend fun clearAllSections() {
        withDatabase {
            queries.deleteAllSections()
        }
    }
}