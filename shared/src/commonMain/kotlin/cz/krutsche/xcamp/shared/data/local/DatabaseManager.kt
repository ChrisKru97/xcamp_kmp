package cz.krutsche.xcamp.shared.data.local

import app.cash.sqldelight.db.SqlDriver
import cz.krutsche.xcamp.shared.db.DatabaseDriverFactory
import cz.krutsche.xcamp.shared.db.XcampDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DatabaseManager(driverFactory: DatabaseDriverFactory) {
    private val driver: SqlDriver = driverFactory.createDriver()
    val database = XcampDatabase(driver)

    val queries = database.xcampDatabaseQueries

    suspend fun clearAllData() {
        withContext(Dispatchers.Default) {
            queries.transaction {
                queries.deleteAllPlaces()
                queries.deleteAllSongs()
                queries.deleteAllSpeakers()
                queries.deleteAllNews()
                queries.deleteAllSections()
            }
        }
    }

    suspend fun hasCachedData(entity: EntityType): Boolean {
        return when (entity) {
            EntityType.PLACES -> queries.countPlaces().executeAsOne() > 0
            EntityType.SPEAKERS -> queries.countSpeakers().executeAsOne() > 0
            EntityType.SECTIONS -> queries.countSections().executeAsOne() > 0
            EntityType.SONGS -> queries.countSongs().executeAsOne() > 0
            EntityType.NEWS -> queries.countNews().executeAsOne() > 0
            EntityType.RATINGS -> false // Online-only feature
            EntityType.USERS -> false // Not user oriented
        }
    }

    suspend fun getLastSyncTime(entity: EntityType): Long? {
        return try {
            queries.getSyncMetadata(entity.collectionName).executeAsOneOrNull()?.lastSyncTime
        } catch (e: Exception) {
            null
        }
    }

    suspend fun updateSyncMetadata(entity: EntityType, syncTime: Long, version: Long = 1L) {
        queries.insertSyncMetadata(entity.collectionName, syncTime, version)
    }
}