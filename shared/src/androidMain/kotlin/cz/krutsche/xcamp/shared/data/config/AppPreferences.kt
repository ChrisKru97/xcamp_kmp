package cz.krutsche.xcamp.shared.data.config

import android.content.Context
import android.content.SharedPreferences
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

actual object AppPreferences {
    private lateinit var context: Context
    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("AppPreferences", Context.MODE_PRIVATE)
    }

    private val json = Json { ignoreUnknownKeys = true }

    fun init(context: Context) {
        this.context = context
    }

    actual fun getAppStateOverride(): AppState? {
        if (!::context.isInitialized) return null
        val value = prefs.getString("appStateOverride", null)
        return value?.let { AppState.valueOf(it) }
    }

    actual fun setAppStateOverride(state: AppState?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (state == null) {
                remove("appStateOverride")
            } else {
                putString("appStateOverride", state.name)
            }
            apply()
        }
    }

    actual fun getNotificationPreferences(): NotificationPreferences {
        return NotificationPreferences() // TODO
    }

    actual fun setNotificationPreferences(preferences: NotificationPreferences) {
        // TODO
    }

    actual fun getDismissedForceUpdateVersion(): String? {
        if (!::context.isInitialized) return null
        return prefs.getString("dismissedForceUpdateVersion", null)
    }

    actual fun setDismissedForceUpdateVersion(version: String?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (version == null) {
                remove("dismissedForceUpdateVersion")
            } else {
                putString("dismissedForceUpdateVersion", version)
            }
            apply()
        }
    }
}
