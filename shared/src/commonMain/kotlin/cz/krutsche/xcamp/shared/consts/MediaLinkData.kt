package cz.krutsche.xcamp.shared.consts

import cz.krutsche.xcamp.shared.localization.Strings

data class MediaLink(
    val title: String,
    val url: String,
    val type: MediaLinkType
)

enum class MediaLinkType {
    Youtube,
    Spotify,
    ApplePodcasts,
    Facebook,
    Instagram,
    Gallery,
    Web
}

val mediaLinkOrder = listOf(
    MediaLinkType.Youtube,
    MediaLinkType.Spotify,
    MediaLinkType.ApplePodcasts,
    MediaLinkType.Facebook,
    MediaLinkType.Instagram,
    MediaLinkType.Web
)

val mediaLinkUrls = mapOf(
    MediaLinkType.Spotify to "https://open.spotify.com/show/6HwtclZ6RZkmUmOoBFppbf",
    MediaLinkType.ApplePodcasts to "https://podcasts.apple.com/us/podcast/festival-xcamp/id1637264212",
    MediaLinkType.Facebook to "https://www.facebook.com/xcamp.cz",
    MediaLinkType.Instagram to "https://www.instagram.com/xcamp.cz/",
    MediaLinkType.Web to "https://www.xcamp.cz"
)

val mediaLinkTitles = mapOf(
    MediaLinkType.Youtube to Strings.Media.YOUTUBE,
    MediaLinkType.Spotify to Strings.Media.SPOTIFY,
    MediaLinkType.ApplePodcasts to Strings.Media.APPLE_PODCASTS,
    MediaLinkType.Facebook to Strings.Media.FACEBOOK,
    MediaLinkType.Instagram to Strings.Media.INSTAGRAM,
    MediaLinkType.Gallery to Strings.Media.GALLERY,
    MediaLinkType.Web to Strings.Media.WEBSITE
)