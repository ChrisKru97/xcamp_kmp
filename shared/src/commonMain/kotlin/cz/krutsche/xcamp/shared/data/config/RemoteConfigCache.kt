package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.Serializable

@Serializable
data class RemoteConfigCache(
    val showAppData: Boolean,
    val startDate: String,
    val qrResetPin: String,
    val mainInfo: String,
    val mediaGallery: String,
    val phone: String,
    val registration: Boolean,
    val youtubePlaylist: String,
    val forceUpdateVersion: String
) {
    companion object {
        val defaults = RemoteConfigCache(
            showAppData = false,
            startDate = "2026-07-18",
            qrResetPin = "7973955",
            mainInfo = "",
            mediaGallery = "https://eu.zonerama.com/xcamp/1274394",
            phone = "+420732378740",
            registration = false,
            youtubePlaylist = "https://www.youtube.com/watch?v=AOFRsBUgjjU&list=PLVFssG93u7cbUrrT8_ocPN055g3EpsUbf",
            forceUpdateVersion = "0.0.0"
        )
    }
}
