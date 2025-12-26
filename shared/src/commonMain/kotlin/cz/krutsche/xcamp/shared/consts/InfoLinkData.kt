package cz.krutsche.xcamp.shared.consts

import cz.krutsche.xcamp.shared.localization.Strings

data class InfoLink(
    val title: String,
    val url: String,
    val type: InfoLinkType
)

enum class InfoLinkType {
    Phone,
    Email,
    Web,
    Map,
    Registration
}

val infoLinkOrder = listOf(
    InfoLinkType.Phone,
    InfoLinkType.Email,
    InfoLinkType.Web,
    InfoLinkType.Map,
    InfoLinkType.Registration
)

val infoLinkUrls = mapOf(
    InfoLinkType.Email to "mailto:info@xcamp.cz",
    InfoLinkType.Web to "https://www.xcamp.cz",
    InfoLinkType.Map to "maps://49.7158,18.5934?name=Smilovice%2079",
    InfoLinkType.Registration to "https://www.xcamp.cz/registrace",
)

val infoLinkTitles = mapOf(
    InfoLinkType.Email to Strings.Info.CONTACT_EMAIL,
    InfoLinkType.Web to Strings.Info.CONTACT_WEB,
    InfoLinkType.Map to Strings.Info.CONTACT_MAP,
    InfoLinkType.Registration to Strings.Info.CONTACT_REGISTRATION
)