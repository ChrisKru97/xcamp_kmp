package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RemoteConfigCache(
    @SerialName("showAppData") private val _showAppData: Boolean? = null,
    @SerialName("startDate") private val _startDate: String? = null,
    @SerialName("qrResetPin") private val _qrResetPin: String? = null,
    @SerialName("mainInfo") private val _mainInfo: String? = null,
    @SerialName("mediaGallery") private val _mediaGallery: String? = null,
    @SerialName("phone") private val _phone: String? = null,
    @SerialName("registration") private val _registration: Boolean? = null,
    @SerialName("youtubePlaylist") private val _youtubePlaylist: String? = null,
    @SerialName("forceUpdateVersion") private val _forceUpdateVersion: String? = null
) {
    val showAppData: Boolean get() = _showAppData ?: false
    val startDate: String get() = _startDate ?: "2026-07-18"
    val qrResetPin: String get() = _qrResetPin ?: "7973955"
    val mainInfo: String get() = _mainInfo ?: ""
    val mediaGallery: String get() = _mediaGallery ?: "https://eu.zonerama.com/xcamp/1274394"
    val phone: String get() = _phone ?: "+420732378740"
    val registration: Boolean get() = _registration ?: false
    val youtubePlaylist: String get() = _youtubePlaylist ?: "https://www.youtube.com/watch?v=AOFRsBUgjjU&list=PLVFssG93u7cbUrrT8_ocPN055g3EpsUbf"
    val forceUpdateVersion: String get() = _forceUpdateVersion ?: "0.0.0"
}
