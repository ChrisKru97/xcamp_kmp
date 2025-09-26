package cz.krutsche.xcamp.shared.data.local

import com.russhwolf.settings.Settings
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class DevConfigService(private val settings: Settings) {

    private val _developmentModeEnabled = MutableStateFlow(
        settings.getBoolean(KEY_DEVELOPMENT_MODE, false)
    )
    val developmentModeEnabled: StateFlow<Boolean> = _developmentModeEnabled.asStateFlow()

    fun setDevelopmentMode(enabled: Boolean) {
        settings.putBoolean(KEY_DEVELOPMENT_MODE, enabled)
        _developmentModeEnabled.value = enabled
    }

    fun getShowAppDataOverride(): Boolean? {
        return if (_developmentModeEnabled.value) {
            if (settings.getBoolean(KEY_SHOW_APP_DATA_OVERRIDE_ENABLED, false)) {
                settings.getBoolean(KEY_SHOW_APP_DATA_OVERRIDE_VALUE, false)
            } else null
        } else null
    }

    fun setShowAppDataOverride(enabled: Boolean?, value: Boolean = false) {
        if (enabled != null) {
            settings.putBoolean(KEY_SHOW_APP_DATA_OVERRIDE_ENABLED, true)
            settings.putBoolean(KEY_SHOW_APP_DATA_OVERRIDE_VALUE, value)
        } else {
            settings.remove(KEY_SHOW_APP_DATA_OVERRIDE_ENABLED)
            settings.remove(KEY_SHOW_APP_DATA_OVERRIDE_VALUE)
        }
    }

    fun getQrResetPinOverride(): String? {
        return if (_developmentModeEnabled.value) {
            if (settings.getBoolean(KEY_QR_RESET_PIN_OVERRIDE_ENABLED, false)) {
                settings.getString(KEY_QR_RESET_PIN_OVERRIDE_VALUE, "1234")
            } else null
        } else null
    }

    fun setQrResetPinOverride(enabled: Boolean?, value: String = "1234") {
        if (enabled != null) {
            settings.putBoolean(KEY_QR_RESET_PIN_OVERRIDE_ENABLED, true)
            settings.putString(KEY_QR_RESET_PIN_OVERRIDE_VALUE, value)
        } else {
            settings.remove(KEY_QR_RESET_PIN_OVERRIDE_ENABLED)
            settings.remove(KEY_QR_RESET_PIN_OVERRIDE_VALUE)
        }
    }

    fun clearAllOverrides() {
        settings.remove(KEY_SHOW_APP_DATA_OVERRIDE_ENABLED)
        settings.remove(KEY_SHOW_APP_DATA_OVERRIDE_VALUE)
        settings.remove(KEY_QR_RESET_PIN_OVERRIDE_ENABLED)
        settings.remove(KEY_QR_RESET_PIN_OVERRIDE_VALUE)
    }

    companion object {
        private const val KEY_DEVELOPMENT_MODE = "development_mode"
        private const val KEY_SHOW_APP_DATA_OVERRIDE_ENABLED = "show_app_data_override_enabled"
        private const val KEY_SHOW_APP_DATA_OVERRIDE_VALUE = "show_app_data_override_value"
        private const val KEY_QR_RESET_PIN_OVERRIDE_ENABLED = "qr_reset_pin_override_enabled"
        private const val KEY_QR_RESET_PIN_OVERRIDE_VALUE = "qr_reset_pin_override_value"
    }
}