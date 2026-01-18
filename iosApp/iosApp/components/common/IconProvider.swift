import SwiftUI
import shared

enum IconProvider {
    static func iconName(for infoLink: InfoLink) -> String {
        iconName(for: infoLink.type)
    }

    static func iconName(for mediaLink: MediaLink) -> String {
        iconName(for: mediaLink.title)
    }

    static func iconName(for type: InfoLinkType) -> String {
        switch type {
        case InfoLinkType.phone: return "phone.fill"
        case InfoLinkType.email: return "envelope.fill"
        case InfoLinkType.web: return "safari.fill"
        case InfoLinkType.map: return "map.fill"
        case InfoLinkType.registration: return "square.and.pencil"
        default: return "link"
        }
    }

    static func iconName(for title: String) -> String {
        switch title {
        case Strings.Media.shared.YOUTUBE: return "play.rectangle.fill"
        case Strings.Media.shared.SPOTIFY: return "music.note"
        case Strings.Media.shared.APPLE_PODCASTS: return "podcast.fill"
        case Strings.Media.shared.FACEBOOK: return "book"
        case Strings.Media.shared.INSTAGRAM: return "camera"
        case Strings.Media.shared.WEBSITE: return "safari.fill"
        default: return "link"
        }
    }
}
