package cz.krutsche.xcamp.shared.data.local

import cz.krutsche.xcamp.shared.db.DatabaseDriverFactory
import cz.krutsche.xcamp.shared.db.XcampDatabase

class DatabaseManager(driverFactory: DatabaseDriverFactory) {
    val database = XcampDatabase(driverFactory.createDriver())

    val queries = database.xcampDatabaseQueries

    suspend fun clearAllData() { // TODO invoke after showAppData turns false and run it once for every year (store last year in settings)
        queries.transaction {
            queries.deleteAllGroupLeaders()
            queries.deleteAllPlaces()
            queries.deleteAllSongs()
            queries.deleteAllSpeakers()
            queries.deleteAllNews()
            queries.deleteAllSections()
            queries.deleteAllRatings()
        }
    }
}