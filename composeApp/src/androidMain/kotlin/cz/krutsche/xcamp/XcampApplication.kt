package cz.krutsche.xcamp

import android.app.Application
import cz.krutsche.xcamp.shared.data.DatabaseFactory
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.context.GlobalContext.startKoin

class XcampApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        DatabaseFactory.init(this)

        startKoin {
            androidLogger()
            androidContext(this@XcampApplication)
            modules(emptyList())
        }
    }
}