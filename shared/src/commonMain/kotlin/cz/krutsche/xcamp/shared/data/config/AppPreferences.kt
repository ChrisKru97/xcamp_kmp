package cz.krutsche.xcamp.shared.data.config

expect object AppPreferences {
    fun getAppStateOverride(): AppState?
    fun setAppStateOverride(state: AppState?)
}
