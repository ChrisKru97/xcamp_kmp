package cz.krutsche.xcamp.shared.data.firebase

import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.config.RemoteConfigCache
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.remoteconfig.FirebaseRemoteConfig
import dev.gitlive.firebase.remoteconfig.remoteConfig
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class RemoteConfigService {
    private val remoteConfig: FirebaseRemoteConfig = Firebase.remoteConfig

    private var cache = RemoteConfigCache()

    init {
        loadCachedValues()
    }

    private fun loadCachedValues() {
        cache = AppPreferences.getRemoteConfigCache() ?: RemoteConfigCache()
    }

    suspend fun initialize(): Result<Unit> = fetchAndActivate()

    suspend fun fetchAndActivate(): Result<Unit> {
        return try {
            withTimeout(10.seconds) {
                remoteConfig.settings {
                    minimumFetchInterval = 3600.seconds
                }
                val fetchResult = remoteConfig.fetchAndActivate()
                if (fetchResult) {
                    updateCacheFromRemoteConfig()
                }
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private suspend fun updateCacheFromRemoteConfig() {
        cache = RemoteConfigCache(
            _showAppData = tryGetBoolean("showAppData"),
            _startDate = tryGetString("startDate"),
            _qrResetPin = tryGetString("qrResetPin"),
            _mainInfo = tryGetString("mainInfo"),
            _mediaGallery = tryGetString("mediaGallery"),
            _phone = tryGetString("phone"),
            _registration = tryGetBoolean("registration"),
            _youtubePlaylist = tryGetString("youtubePlaylist"),
            _forceUpdateVersion = tryGetString("force_update_version")
        )
        AppPreferences.setRemoteConfigCache(cache)
    }

    private fun tryGetBoolean(key: String): Boolean? {
        return try {
            remoteConfig.getValue(key).asBoolean()
        } catch (e: Exception) {
            null
        }
    }

    private fun tryGetString(key: String): String? {
        return try {
            val value = remoteConfig.getValue(key).asString()
            value.ifEmpty { null }
        } catch (e: Exception) {
            null
        }
    }

    val showAppData: Boolean get() = cache.showAppData
    val startDate: String get() = cache.startDate
    val mainInfo: String get() = cache.mainInfo
    val galleryLink: String get() = cache.mediaGallery
    val contactPhone: String get() = cache.phone
    val showRegistration: Boolean get() = cache.registration
    val youtubeLink: String get() = cache.youtubePlaylist
    val forceUpdateVersion: String get() = cache.forceUpdateVersion
}
