package cz.krutsche.xcamp.shared.db

import android.content.Context
import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.android.AndroidSqliteDriver
import cz.krutsche.xcamp.shared.data.local.SchemaMigrations

actual class DatabaseDriverFactory(private val context: Context) {
    actual fun createDriver(): SqlDriver {
        val driver = AndroidSqliteDriver(XcampDatabase.Schema, context, "xcamp.db")
        XcampDatabase.Schema.migrate(driver, 1, 1, *SchemaMigrations.migrations)
        return driver
    }
}