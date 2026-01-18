package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.local.DatabaseManager

expect object DatabaseFactory {
    fun getDatabaseManager(): DatabaseManager
}
