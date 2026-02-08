package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import platform.Foundation.NSUserDefaults

actual object AppPreferences {
    private const val KEY_APP_STATE_OVERRIDE = "appStateOverride"
    private const val KEY_NOTIFICATION_PREFERENCES = "notificationPreferences"

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
}
