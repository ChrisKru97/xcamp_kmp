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

    private const val KEY_APP_STATE_OVERRIDE = "appStateOverride"
    private const val KEY_NOTIFICATION_PREFERENCES = "notificationPreferences"
    private const val KEY_DISMISSED_FORCE_UPDATE_VERSION = "dismissedForceUpdateVersion"
    private const val KEY_REMOTE_CONFIG_CACHE = "remoteConfigCache"
    private const val KEY_DATA_COLLECTION_ENABLED = "dataCollectionEnabled"

    private val json = Json { ignoreUnknownKeys = true }

    actual fun setAppStateOverride(state: AppState?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (state == null) {
                remove(KEY_APP_STATE_OVERRIDE)
            } else {
                putString(KEY_APP_STATE_OVERRIDE, state.name)
            }
            apply()
        }
    }

    actual fun getNotificationPreferences(): NotificationPreferences {
        if (!::context.isInitialized) return NotificationPreferences()
        val value = prefs.getString(KEY_NOTIFICATION_PREFERENCES, null)
        return value?.let {
            try {
                json.decodeFromString<NotificationPreferences>(it)
            } catch (e: Exception) {
                prefs.edit().remove(KEY_NOTIFICATION_PREFERENCES).apply()
                NotificationPreferences()
            }
        } ?: NotificationPreferences()
    }

    actual fun setNotificationPreferences(preferences: NotificationPreferences) {
        if (!::context.isInitialized) return
        val encoded = json.encodeToString(preferences)
        prefs.edit().putString(KEY_NOTIFICATION_PREFERENCES, encoded).apply()
    }

    actual fun getDismissedForceUpdateVersion(): String? {
        if (!::context.isInitialized) return null
        return prefs.getString(KEY_DISMISSED_FORCE_UPDATE_VERSION, null)
    }

    actual fun setDismissedForceUpdateVersion(version: String?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (version == null) {
                remove(KEY_DISMISSED_FORCE_UPDATE_VERSION)
            } else {
                putString(KEY_DISMISSED_FORCE_UPDATE_VERSION, version)
            }
            apply()
        }
    }

    actual fun getRemoteConfigCache(): RemoteConfigCache? {
        if (!::context.isInitialized) return null
        val value = prefs.getString(KEY_REMOTE_CONFIG_CACHE, null)
        return value?.let {
            try {
                json.decodeFromString<RemoteConfigCache>(it)
            } catch (e: Exception) {
                prefs.edit().remove(KEY_REMOTE_CONFIG_CACHE).apply()
                null
            }
        }
    }

    actual fun setRemoteConfigCache(cache: RemoteConfigCache?) {
        if (!::context.isInitialized) return
        prefs.edit().apply {
            if (cache == null) {
                remove(KEY_REMOTE_CONFIG_CACHE)
            } else {
                putString(KEY_REMOTE_CONFIG_CACHE, json.encodeToString(cache))
            }
            apply()
        }
    }

    actual fun getDataCollectionEnabled(): Boolean {
        if (!::context.isInitialized) return true
        return prefs.getBoolean(KEY_DATA_COLLECTION_ENABLED, true)
    }

    actual fun setDataCollectionEnabled(enabled: Boolean) {
        if (!::context.isInitialized) return
        prefs.edit().putBoolean(KEY_DATA_COLLECTION_ENABLED, enabled).apply()
    }
}
