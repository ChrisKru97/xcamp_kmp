package cz.krutsche.xcamp.shared.data.config

import platform.Foundation.NSUserDefaults

actual object AppPreferences {
    private const val KEY_APP_STATE_OVERRIDE = "appStateOverride"

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
}
