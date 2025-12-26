package cz.krutsche.xcamp.shared.utils

import cz.krutsche.xcamp.shared.consts.InfoLink
import cz.krutsche.xcamp.shared.consts.InfoLinkType
import cz.krutsche.xcamp.shared.consts.MediaLink
import cz.krutsche.xcamp.shared.consts.MediaLinkType
import cz.krutsche.xcamp.shared.consts.infoLinkOrder
import cz.krutsche.xcamp.shared.consts.infoLinkTitles
import cz.krutsche.xcamp.shared.consts.infoLinkUrls
import cz.krutsche.xcamp.shared.consts.mediaLinkOrder
import cz.krutsche.xcamp.shared.consts.mediaLinkTitles
import cz.krutsche.xcamp.shared.consts.mediaLinkUrls
import cz.krutsche.xcamp.shared.localization.Strings

object LinkUtils {
    fun getInfoItems(phone: String, showRegistration: Boolean): List<InfoLink> {
        return infoLinkOrder.filter {
            it != InfoLinkType.Registration || showRegistration
        }.map { type ->
            InfoLink(
                type = type,
                url = infoLinkUrls[type] ?: when (type) {
                    InfoLinkType.Phone -> "tel:$phone"
                    else -> ""
                },
                title = infoLinkTitles[type] ?: when (type) {
                    InfoLinkType.Phone -> "${Strings.Info.CONTACT_PHONE_LABEL} $phone"
                    else -> ""
                }
            )
        }
    }

    fun getMediaItems(youtubePlaylist: String, mediaGallery: String): List<MediaLink> {
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
}