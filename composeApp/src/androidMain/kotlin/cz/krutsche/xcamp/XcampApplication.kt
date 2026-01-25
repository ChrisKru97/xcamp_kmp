package cz.krutsche.xcamp

import android.app.Application
import cz.krutsche.xcamp.shared.data.DatabaseFactory

class XcampApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        DatabaseFactory.init(this)
    }
}
