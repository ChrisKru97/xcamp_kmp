package cz.krutsche.xcamp.shared.data

import android.content.Context
import cz.krutsche.xcamp.shared.data.local.DatabaseManager
import cz.krutsche.xcamp.shared.db.DatabaseDriverFactory

actual object DatabaseFactory {
    private lateinit var context: Context
    private val _databaseManager: DatabaseManager by lazy { DatabaseManager(DatabaseDriverFactory(context)) }

    fun init(context: Context) {
        this.context = context
    }

    actual fun getDatabaseManager(): DatabaseManager = _databaseManager
}
