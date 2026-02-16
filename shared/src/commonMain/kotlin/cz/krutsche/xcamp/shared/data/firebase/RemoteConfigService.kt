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
            _showAppData = runCatching { remoteConfig.getValue("showAppData").asBoolean() }.getOrNull(),
            _startDate = runCatching { remoteConfig.getValue("startDate").asString().ifEmpty { null } }.getOrNull(),
            _qrResetPin = runCatching { remoteConfig.getValue("qrResetPin").asString().ifEmpty { null } }.getOrNull(),
            _mainInfo = runCatching { remoteConfig.getValue("mainInfo").asString().ifEmpty { null } }.getOrNull(),
            _mediaGallery = runCatching { remoteConfig.getValue("mediaGallery").asString().ifEmpty { null } }.getOrNull(),
            _phone = runCatching { remoteConfig.getValue("phone").asString().ifEmpty { null } }.getOrNull(),
            _registration = runCatching { remoteConfig.getValue("registration").asBoolean() }.getOrNull(),
            _youtubePlaylist = runCatching { remoteConfig.getValue("youtubePlaylist").asString().ifEmpty { null } }.getOrNull(),
            _forceUpdateVersion = runCatching { remoteConfig.getValue("force_update_version").asString().ifEmpty { null } }.getOrNull()
        )
        AppPreferences.setRemoteConfigCache(cache)
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
