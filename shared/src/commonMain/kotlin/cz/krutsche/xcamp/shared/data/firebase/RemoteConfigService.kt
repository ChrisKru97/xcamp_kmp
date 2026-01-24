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
                    minimumFetchInterval = 3600.seconds
                }

                remoteConfig.fetchAndActivate()
                Result.success(Unit)
            }
        } catch (e: Exception) {
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
        return true
        // val actualValue = getBoolean("showAppData")
        // return actualValue
    }

    fun getStartDate(): String {
        return getString("startDate").ifEmpty { "2026-07-18" }
    }

    fun getQrResetPin(): String {
        return getString("qrResetPin").ifEmpty { "7973955" }
    }

    fun getMainInfo(): String {
        return getString("mainInfo")
    }

    fun getGalleryLink(): String {
        return getString("mediaGallery").ifEmpty { "https://eu.zonerama.com/xcamp/1274394" }
    }

    fun getContactPhone(): String {
        return getString("phone").ifEmpty { "+420732378740" }
    }

    fun getShowRegistration(): Boolean {
        return getBoolean("registration")
    }

    fun getYoutubeLink(): String {
        return getString("youtubePlaylist").ifEmpty { "https://www.youtube.com/watch?v=AOFRsBUgjjU&list=PLVFssG93u7cbUrrT8_ocPN055g3EpsUbf" }
    }
}
