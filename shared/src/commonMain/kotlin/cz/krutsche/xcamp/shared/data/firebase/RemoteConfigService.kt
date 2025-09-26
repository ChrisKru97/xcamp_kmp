package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.remoteconfig.FirebaseRemoteConfig
import dev.gitlive.firebase.remoteconfig.remoteConfig
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class RemoteConfigService {
    private val remoteConfig: FirebaseRemoteConfig = Firebase.remoteConfig

    suspend fun initialize(): Result<Unit> {
        return try {
            withTimeout(10.seconds) {
                remoteConfig.settings {
                    minimumFetchIntervalInSeconds = 3600 // 1 hour
                }

                // Set default values
                remoteConfig.setDefaults(
                    "showAppData" to false,
                    "startDate" to "2026-07-18",
                    "qrResetPin" to "1234"
                )

                // Fetch and activate
                remoteConfig.fetchAndActivate()
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun getBoolean(key: String): Boolean {
        return try {
            val value = remoteConfig.getValue(key)
            value.asBoolean()
        } catch (e: Exception) {
            getDefaultBoolean(key)
        }
    }

    fun getString(key: String): String {
        return try {
            val value = remoteConfig.getValue(key)
            value.asString()
        } catch (e: Exception) {
            getDefaultString(key)
        }
    }

    fun getLong(key: String): Long {
        return try {
            val value = remoteConfig.getValue(key)
            value.asLong()
        } catch (e: Exception) {
            getDefaultLong(key)
        }
    }

    fun getDouble(key: String): Double {
        return try {
            val value = remoteConfig.getValue(key)
            value.asDouble()
        } catch (e: Exception) {
            getDefaultDouble(key)
        }
    }

    // App-specific feature flags
    fun shouldShowAppData(): Boolean = getBoolean("showAppData")

    fun getStartDate(): String = getString("startDate")

    fun getQrResetPin(): String = getString("qrResetPin")

    // Default values for fallback
    private fun getDefaultBoolean(key: String): Boolean {
        return when (key) {
            "showAppData" -> false
            else -> false
        }
    }

    private fun getDefaultString(key: String): String {
        return when (key) {
            "startDate" -> "2026-07-18"
            "qrResetPin" -> "1234"
            else -> ""
        }
    }

    private fun getDefaultLong(key: String): Long {
        return when (key) {
            else -> 0L
        }
    }

    private fun getDefaultDouble(key: String): Double {
        return when (key) {
            else -> 0.0
        }
    }

    suspend fun refresh(): Result<Unit> {
        return try {
            withTimeout(10.seconds) {
                remoteConfig.fetchAndActivate()
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}