package cz.krutsche.xcamp.shared.consts

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
    Gallery
}

val mediaLinkOrder = listOf(
    MediaLinkType.Youtube,
    MediaLinkType.Spotify,
    MediaLinkType.ApplePodcasts,
    MediaLinkType.Facebook,
    MediaLinkType.Instagram,
    MediaLinkType.Gallery
)

val mediaLinkUrls = mapOf(
    MediaLinkType.Spotify to "https://open.spotify.com/show/6HwtclZ6RZkmUmOoBFppbf",
    MediaLinkType.ApplePodcasts to "https://podcasts.apple.com/us/podcast/festival-xcamp/id1637264212",
    MediaLinkType.Facebook to "https://www.facebook.com/xcamp.cz",
    MediaLinkType.Instagram to "https://www.instagram.com/xcamp.cz/"
)

val mediaLinkTitles = mapOf(
    MediaLinkType.Youtube to "YouTube",
    MediaLinkType.Spotify to "Spotify",
    MediaLinkType.ApplePodcasts to "Apple Podcasts",
    MediaLinkType.Facebook to "Facebook",
    MediaLinkType.Instagram to "Instagram",
    MediaLinkType.Gallery to "Galerie"
)