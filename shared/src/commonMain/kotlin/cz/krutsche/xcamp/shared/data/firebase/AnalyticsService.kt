package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.analytics.FirebaseAnalytics
import dev.gitlive.firebase.analytics.analytics

class AnalyticsService {
    private val analytics: FirebaseAnalytics = Firebase.analytics

    fun logEvent(eventName: String, parameters: Map<String, Any> = emptyMap()) {
        try {
            analytics.logEvent(eventName, parameters)
        } catch (e: Exception) {
            // Log error but don't crash the app
            println("Analytics error: ${e.message}")
        }
    }

    fun setUserId(userId: String) {
        try {
            analytics.setUserId(userId)
        } catch (e: Exception) {
            println("Analytics setUserId error: ${e.message}")
        }
    }

    fun setUserProperty(name: String, value: String) {
        try {
            analytics.setUserProperty(name, value)
        } catch (e: Exception) {
            println("Analytics setUserProperty error: ${e.message}")
        }
    }

    fun setAnalyticsCollectionEnabled(enabled: Boolean) {
        try {
            analytics.setAnalyticsCollectionEnabled(enabled)
        } catch (e: Exception) {
            println("Analytics setAnalyticsCollectionEnabled error: ${e.message}")
        }
    }

    // Common event names
    object Events {
        const val SCREEN_VIEW = "screen_view"
        const val TAB_SWITCH = "tab_switch"
        const val SECTION_VIEW = "section_view"
        const val SPEAKER_VIEW = "speaker_view"
        const val PLACE_VIEW = "place_view"
        const val SONG_VIEW = "song_view"
        const val QR_SCAN = "qr_scan"
        const val FAVORITE_TOGGLE = "favorite_toggle"
        const val PHOTO_UPLOAD = "photo_upload"
        const val RATING_SUBMIT = "rating_submit"
    }
}