package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.remoteconfig.FirebaseRemoteConfig
import dev.gitlive.firebase.remoteconfig.remoteConfig
import io.github.aakira.napier.Napier
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class RemoteConfigService {
    private val remoteConfig: FirebaseRemoteConfig = Firebase.remoteConfig

    suspend fun initialize(): Result<Unit> {
        Napier.i(tag = "RemoteConfigService") { "Starting Remote Config initialization..." }
        return try {
            withTimeout(10.seconds) {
                remoteConfig.settings {
                    minimumFetchInterval = 3600.seconds
                }

                val fetchResult = remoteConfig.fetchAndActivate()
                Napier.i(tag = "RemoteConfigService") { "Remote Config fetch and activate completed: $fetchResult" }
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Napier.e(tag = "RemoteConfigService", throwable = e) { "Remote Config initialization failed: ${e.message}" }
            Result.failure(e)
        }
    }

    private fun getBoolean(key: String): Boolean {
        val value = remoteConfig.getValue(key)
        return value.asBoolean()
    }

    private fun getString(key: String): String {
        val value = remoteConfig.getValue(key)
        return value.asString()
    }

    fun shouldShowAppData(): Boolean {
        // TEMPORARY: Force return true for testing Firestore integration
        // TODO: Remove this after verifying Firestore data fetching works
        Napier.d(tag = "RemoteConfigService") { "shouldShowAppData() called - returning HARDCODED true (for testing)" }
        return true
        // val actualValue = getBoolean("showAppData")
        // Napier.d(tag = "RemoteConfigService") { "shouldShowAppData() actual Remote Config value: $actualValue" }
        // return actualValue
    }

    fun getStartDate(): String {
        val value = getString("startDate").ifEmpty { "2026-07-18" }
        Napier.d(tag = "RemoteConfigService") { "getStartDate() = '$value'" }
        return value
    }

    fun getQrResetPin(): String {
        val value = getString("qrResetPin").ifEmpty { "7973955" }
        Napier.d(tag = "RemoteConfigService") { "getQrResetPin() = '$value'" }
        return value
    }

    fun getMainInfo(): String {
        val value = getString("mainInfo")
        Napier.d(tag = "RemoteConfigService") { "getMainInfo() = '$value'" }
        return value
    }

    fun getGalleryLink(): String {
        val value = getString("mediaGallery").ifEmpty { "https://eu.zonerama.com/xcamp/1274394" }
        Napier.d(tag = "RemoteConfigService") { "getGalleryLink() = '$value'" }
        return value
    }

    fun getContactPhone(): String {
        val value = getString("phone").ifEmpty { "+420732378740" }
        Napier.d(tag = "RemoteConfigService") { "getContactPhone() = '$value'" }
        return value
    }

    fun getShowRegistration(): Boolean {
        val value = getBoolean("registration")
        Napier.d(tag = "RemoteConfigService") { "getShowRegistration() = $value" }
        return value
    }

    fun getYoutubeLink(): String {
        val value = getString("youtubePlaylist").ifEmpty { "https://www.youtube.com/watch?v=AOFRsBUgjjU&list=PLVFssG93u7cbUrrT8_ocPN055g3EpsUbf" }
        Napier.d(tag = "RemoteConfigService") { "getYoutubeLink() = '$value'" }
        return value
    }
}