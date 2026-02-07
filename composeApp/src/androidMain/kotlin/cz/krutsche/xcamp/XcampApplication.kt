package cz.krutsche.xcamp

import android.app.Application
import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.config.AppPreferences

class XcampApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        DatabaseFactory.init(this)
        AppPreferences.init(this)
    }
}
