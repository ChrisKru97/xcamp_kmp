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

    suspend fun clearAllData() { // TODO invoke after showAppData turns false and run it once for every year (store last year in settings)
        withContext(Dispatchers.Default) {
            queries.transaction {
                queries.deleteAllPlaces()
                queries.deleteAllSongs()
                queries.deleteAllSpeakers()
                queries.deleteAllNews()
                queries.deleteAllSections()
                queries.deleteAllRatings()
            }
        }
    }

    suspend fun getLastSyncTime(entity: String): Long? = withContext(Dispatchers.Default) {
        try {
            queries.getSyncMetadata(entity).executeAsOneOrNull()?.lastSyncTime
        } catch (e: Exception) {
            null
        }
    }

    suspend fun updateSyncMetadata(entity: String, syncTime: Long, version: Long = 1L) = withContext(Dispatchers.Default) {
        queries.insertSyncMetadata(entity, syncTime, version)
    }
}