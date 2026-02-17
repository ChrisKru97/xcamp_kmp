package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import platform.Foundation.NSUserDefaults

actual object AppPreferences {
    private const val KEY_NOTIFICATION_PREFERENCES = "notificationPreferences"
    private const val KEY_DISMISSED_FORCE_UPDATE_VERSION = "dismissedForceUpdateVersion"
    private const val KEY_REMOTE_CONFIG_CACHE = "remoteConfigCache"
    private const val KEY_DATA_COLLECTION_ENABLED = "dataCollectionEnabled"

    private val json = Json { ignoreUnknownKeys = true }

    actual fun getNotificationPreferences(): NotificationPreferences {
        val value = NSUserDefaults.standardUserDefaults.stringForKey(KEY_NOTIFICATION_PREFERENCES)
        return value?.let {
            try {
                json.decodeFromString<NotificationPreferences>(it)
            } catch (e: Exception) {
                NSUserDefaults.standardUserDefaults.removeObjectForKey(KEY_NOTIFICATION_PREFERENCES)
                NotificationPreferences()
            }
        } ?: NotificationPreferences()
    }

    actual fun setNotificationPreferences(preferences: NotificationPreferences) {
        val encoded = json.encodeToString(preferences)
        NSUserDefaults.standardUserDefaults.setObject(encoded, KEY_NOTIFICATION_PREFERENCES)
    }

    actual fun getDismissedForceUpdateVersion(): String? {
        return NSUserDefaults.standardUserDefaults.stringForKey(KEY_DISMISSED_FORCE_UPDATE_VERSION)
    }

    actual fun setDismissedForceUpdateVersion(version: String?) {
        if (version == null) {
            NSUserDefaults.standardUserDefaults.removeObjectForKey(KEY_DISMISSED_FORCE_UPDATE_VERSION)
        } else {
            NSUserDefaults.standardUserDefaults.setObject(version, KEY_DISMISSED_FORCE_UPDATE_VERSION)
        }
    }

    actual fun getRemoteConfigCache(): RemoteConfigCache? {
        val value = NSUserDefaults.standardUserDefaults.stringForKey(KEY_REMOTE_CONFIG_CACHE)
        return value?.let {
            try {
                json.decodeFromString<RemoteConfigCache>(it)
            } catch (e: Exception) {
                NSUserDefaults.standardUserDefaults.removeObjectForKey(KEY_REMOTE_CONFIG_CACHE)
                null
            }
        }
    }

    actual fun setRemoteConfigCache(cache: RemoteConfigCache?) {
        if (cache == null) {
            NSUserDefaults.standardUserDefaults.removeObjectForKey(KEY_REMOTE_CONFIG_CACHE)
        } else {
            val encoded = json.encodeToString(cache)
            NSUserDefaults.standardUserDefaults.setObject(encoded, KEY_REMOTE_CONFIG_CACHE)
        }
    }

    actual fun getDataCollectionEnabled(): Boolean {
        return if (NSUserDefaults.standardUserDefaults.objectForKey(KEY_DATA_COLLECTION_ENABLED) == null) {
            true
        } else {
            NSUserDefaults.standardUserDefaults.boolForKey(KEY_DATA_COLLECTION_ENABLED)
        }
    }

    actual fun setDataCollectionEnabled(enabled: Boolean) {
        NSUserDefaults.standardUserDefaults.setBool(enabled, KEY_DATA_COLLECTION_ENABLED)
    }
}
