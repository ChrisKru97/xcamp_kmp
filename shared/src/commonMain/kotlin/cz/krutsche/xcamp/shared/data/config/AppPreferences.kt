package cz.krutsche.xcamp.shared.data.config

expect object AppPreferences {
    fun getAppStateOverride(): AppState?
    fun setAppStateOverride(state: AppState?)

    fun getNotificationPreferences(): NotificationPreferences
    fun setNotificationPreferences(preferences: NotificationPreferences)

    fun getDismissedForceUpdateVersion(): String?
    fun setDismissedForceUpdateVersion(version: String?)

    fun getRemoteConfigCache(): RemoteConfigCache?
    fun setRemoteConfigCache(cache: RemoteConfigCache?)
}
