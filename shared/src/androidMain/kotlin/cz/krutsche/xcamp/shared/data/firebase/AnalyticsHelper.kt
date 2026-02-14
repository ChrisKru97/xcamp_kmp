package cz.krutsche.xcamp.shared.data.firebase

import com.google.firebase.ktx.Firebase
import com.google.firebase.analytics.ktx.analytics

object AnalyticsHelper {
    private val analytics = Firebase.analytics

    fun setUserId(userId: String?) {
        analytics.setUserId(userId)
    }

    fun setUserProperty(name: String, value: String?) {
        analytics.setUserProperty(name, value)
    }

    fun logEvent(name: String, parameters: Map<String, String?>) {
        val bundle = android.os.Bundle().apply {
            parameters.forEach { (key, value) ->
                if (value != null) {
                    putString(key, value)
                }
            }
        }
        analytics.logEvent(name, bundle)
    }
}
