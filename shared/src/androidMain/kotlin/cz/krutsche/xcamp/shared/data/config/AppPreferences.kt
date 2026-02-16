package cz.krutsche.xcamp.shared.data.config

import android.content.Context
import android.content.SharedPreferences
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

actual object AppPreferences {
    lateinit var context: Context
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
        if (!::context.isInitialized) return NotificationPreferences()
        val value = prefs.getString("notificationPreferences", null)
        return value?.let {
            try {
                json.decodeFromString<NotificationPreferences>(it)
            } catch (e: Exception) {
                prefs.edit().remove("notificationPreferences").apply()
                NotificationPreferences()
            }
        } ?: NotificationPreferences()
    }

    actual fun setNotificationPreferences(preferences: NotificationPreferences) {
        if (!::context.isInitialized) return
        val encoded = json.encodeToString(preferences)
        prefs.edit().putString("notificationPreferences", encoded).apply()
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

    actual fun getRemoteConfigCache(): RemoteConfigCache? {
        if (!::context.isInitialized) return null
        val value = prefs.getString("remoteConfigCache", null)
        return value?.let {
            try {
                json.decodeFromString<RemoteConfigCache>(it)
            } catch (e: Exception) {
                prefs.edit().remove("remoteConfigCache").apply()
                null
            }
        }
    }

    actual fun setRemoteConfigCache(cache: RemoteConfigCache?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (cache == null) {
                remove("remoteConfigCache")
            } else {
                putString("remoteConfigCache", json.encodeToString(cache))
            }
            apply()
        }
    }

    actual fun getDataCollectionEnabled(): Boolean {
        if (!::context.isInitialized) return true
        return prefs.getBoolean("dataCollectionEnabled", true)
    }

    actual fun setDataCollectionEnabled(enabled: Boolean) {
        if (!::context.isInitialized) return
        prefs.edit().putBoolean("dataCollectionEnabled", enabled).apply()
    }
}
