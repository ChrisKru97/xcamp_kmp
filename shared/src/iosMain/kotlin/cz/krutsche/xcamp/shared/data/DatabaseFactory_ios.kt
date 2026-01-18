package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.db.DatabaseDriverFactory

actual object DatabaseFactory {
    private val databaseManager: DatabaseManager by lazy {
        DatabaseManager(DatabaseDriverFactory())
    }

    actual fun getDatabaseManager(): DatabaseManager = databaseManager
}
