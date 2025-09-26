package cz.krutsche.xcamp.shared.db

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.native.NativeSqliteDriver

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(
            schema = XcampDatabase.Schema,
            name = "xcamp.db"
        )
    }
}