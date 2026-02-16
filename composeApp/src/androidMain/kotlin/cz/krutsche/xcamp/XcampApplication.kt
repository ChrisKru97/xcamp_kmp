package cz.krutsche.xcamp

import android.app.Application
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.crashlytics.ktx.crashlytics
import com.google.firebase.ktx.Firebase
import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.firebase.Analytics
import Platform

class XcampApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        DatabaseFactory.init(this)
        AppPreferences.init(this)
        configureCrashlytics()
        configureAnalytics()
    }

    private fun configureCrashlytics() {
        val enabled = AppPreferences.getDataCollectionEnabled()
        val crashlytics = Firebase.crashlytics
        crashlytics.setCrashlyticsCollectionEnabled(enabled)

        if (!enabled) return

        val platform = Platform()

        crashlytics.setCustomKey("app_version", platform.appVersion)
        crashlytics.setCustomKey("build_number", platform.buildNumber)
        crashlytics.setCustomKey("build_type", platform.buildType)
        crashlytics.setCustomKey("os_version", platform.version)
        crashlytics.setCustomKey("device_model", platform.model)
        crashlytics.setCustomKey("device_name", platform.name)
        crashlytics.setCustomKey("locale", platform.locale)
        crashlytics.setCustomKey("screen_size", platform.screenSize)
        crashlytics.setCustomKey("system_name", platform.systemName)

        val auth = ServiceFactory.getAuthService()
        auth.currentUserId?.let { userId ->
            crashlytics.setUserId(userId)
        }
    }

    private fun configureAnalytics() {
        val enabled = AppPreferences.getDataCollectionEnabled()
        Analytics.initializeAnalytics(enabled)

        if (!enabled) return

        val platform = Platform()

        Analytics.setUserProperty("app_version", platform.appVersion)
        Analytics.setUserProperty("build_type", platform.buildType)
        Analytics.setUserProperty("locale", platform.locale)

        val auth = ServiceFactory.getAuthService()
        auth.currentUserId?.let { userId ->
            Analytics.setUserId(userId)
        }
    }
}
