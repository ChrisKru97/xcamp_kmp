package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.consts.InfoLink
import cz.krutsche.xcamp.shared.consts.MediaLink
import cz.krutsche.xcamp.shared.consts.MediaLinkType
import cz.krutsche.xcamp.shared.consts.mediaLinkOrder
import cz.krutsche.xcamp.shared.consts.mediaLinkTitles
import cz.krutsche.xcamp.shared.consts.mediaLinkUrls
import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import cz.krutsche.xcamp.shared.utils.LinkUtils

class LinksService(
    private val remoteConfigService: RemoteConfigService
) {
    fun getMediaLinks(): List<MediaLink> {
        val youtubePlaylist = remoteConfigService.youtubeLink
        val mediaGallery = remoteConfigService.galleryLink

        return mediaLinkOrder.map { type ->
            MediaLink(
                type = type,
                url = when (type) {
                    MediaLinkType.Youtube -> youtubePlaylist
                    MediaLinkType.Gallery -> mediaGallery
                    else -> mediaLinkUrls[type] ?: ""
                },
                title = mediaLinkTitles[type] ?: ""
            )
        }
    }

    fun getInfoLinks(): List<InfoLink> = LinkUtils.getInfoItems(
        phone = remoteConfigService.contactPhone,
        showRegistration = remoteConfigService.showRegistration
    )
}
