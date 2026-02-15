package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import platform.Foundation.NSUserDefaults

actual object AppPreferences {
    private const val KEY_APP_STATE_OVERRIDE = "appStateOverride"
    private const val KEY_NOTIFICATION_PREFERENCES = "notificationPreferences"
    private const val KEY_DISMISSED_FORCE_UPDATE_VERSION = "dismissedForceUpdateVersion"
    private const val KEY_REMOTE_CONFIG_CACHE = "remoteConfigCache"
    private const val KEY_ANALYTICS_CONSENT = "analyticsConsent"

    private val json = Json { ignoreUnknownKeys = true }

    actual fun getAppStateOverride(): AppState? {
        val value = NSUserDefaults.standardUserDefaults.stringForKey(KEY_APP_STATE_OVERRIDE)
        return value?.let { AppState.valueOf(it) }
    }

    actual fun setAppStateOverride(state: AppState?) {
        if (state == null) {
            NSUserDefaults.standardUserDefaults.removeObjectForKey(KEY_APP_STATE_OVERRIDE)
        } else {
            NSUserDefaults.standardUserDefaults.setObject(state.name, KEY_APP_STATE_OVERRIDE)
        }
    }

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

    actual fun getAnalyticsConsent(): Boolean {
        val value = NSUserDefaults.standardUserDefaults.stringForKey(KEY_ANALYTICS_CONSENT)
        return value?.toBooleanStrictOrNull() ?: false
    }

    actual fun setAnalyticsConsent(consent: Boolean) {
        NSUserDefaults.standardUserDefaults.setObject(consent.toString(), KEY_ANALYTICS_CONSENT)
    }
}
