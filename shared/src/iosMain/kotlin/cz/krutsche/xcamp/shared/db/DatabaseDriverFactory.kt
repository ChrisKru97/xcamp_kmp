package cz.krutsche.xcamp.shared.db

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver
import cz.krutsche.xcamp.shared.data.local.SchemaMigrations

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        val driver = NativeSqliteDriver(
            schema = XcampDatabase.Schema,
            name = "xcamp.db"
        )
        XcampDatabase.Schema.migrate(driver, 1, 1, *SchemaMigrations.migrations)
        return driver
    }
}