package cz.krutsche.xcamp.shared.data.config

import android.content.Context
import android.content.SharedPreferences

actual object AppPreferences {
    private lateinit var context: Context
    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("AppPreferences", Context.MODE_PRIVATE)
    }

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
}
