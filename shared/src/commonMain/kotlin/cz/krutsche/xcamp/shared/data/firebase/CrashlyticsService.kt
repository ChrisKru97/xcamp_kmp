package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.crashlytics.crashlytics

class CrashlyticsService {
    private val crashlytics = Firebase.crashlytics

    fun recordException(throwable: Throwable, message: String? = null) {
        try {
            if (message != null) {
                crashlytics.log(message)
            }
            crashlytics.recordException(throwable)
        } catch (e: Exception) {
            // Fail silently - we don't want Crashlytics issues to crash the app
            println("Crashlytics error: ${e.message}")
        }
    }

    fun log(message: String) {
        try {
            crashlytics.log(message)
        } catch (e: Exception) {
            println("Crashlytics log error: ${e.message}")
        }
    }

    fun setUserId(userId: String) {
        try {
            crashlytics.setUserId(userId)
        } catch (e: Exception) {
            println("Crashlytics setUserId error: ${e.message}")
        }
    }

    fun setCustomKey(key: String, value: String) {
        try {
            crashlytics.setCustomKey(key, value)
        } catch (e: Exception) {
            println("Crashlytics setCustomKey error: ${e.message}")
        }
    }

    fun setCrashlyticsCollectionEnabled(enabled: Boolean) {
        try {
            crashlytics.setCrashlyticsCollectionEnabled(enabled)
        } catch (e: Exception) {
            println("Crashlytics setCrashlyticsCollectionEnabled error: ${e.message}")
        }
    }
}