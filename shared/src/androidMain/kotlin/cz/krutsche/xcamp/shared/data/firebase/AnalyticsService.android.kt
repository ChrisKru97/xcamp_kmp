package cz.krutsche.xcamp.shared.data.firebase

import android.os.Bundle
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.ktx.Firebase

actual object AnalyticsService {
    private val firebaseAnalytics = Firebase.analytics

    actual fun logEvent(name: String, parameters: Map<String, String?>) {
        val bundle = Bundle().apply {
            parameters.forEach { (key, value) ->
                if (value != null) {
                    putString(key, value)
                }
            }
        }
        firebaseAnalytics.logEvent(name, bundle)
    }

    actual fun setUserId(userId: String?) {
        firebaseAnalytics.setUserId(userId)
    }

    actual fun setUserProperty(name: String, value: String?) {
        firebaseAnalytics.setUserProperty(name, value)
    }

    actual fun resetAnalyticsData() {
        firebaseAnalytics.resetAnalyticsData()
    }
}
