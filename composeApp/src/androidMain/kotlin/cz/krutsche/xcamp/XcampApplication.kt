package cz.krutsche.xcamp

import android.app.Application
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.crashlytics.ktx.crashlytics
import com.google.firebase.ktx.Firebase
import cz.krutsche.xcamp.shared.data.DatabaseFactory
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.ServiceFactory
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
        val crashlytics = Firebase.crashlytics
        crashlytics.setCrashlyticsCollectionEnabled(true)

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
        val analytics = Firebase.analytics
        val hasConsent = AppPreferences.getAnalyticsConsent()
        analytics.setAnalyticsCollectionEnabled(hasConsent)

        if (!hasConsent) return

        val platform = Platform()

        analytics.setUserProperty("app_version", platform.appVersion)
        analytics.setUserProperty("build_type", platform.buildType)
        analytics.setUserProperty("locale", platform.locale)

        val auth = ServiceFactory.getAuthService()
        auth.currentUserId?.let { userId ->
            analytics.setUserId(userId)
        }
    }
}
