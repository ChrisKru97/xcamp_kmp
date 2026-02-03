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
        case InfoLinkType.web: return "globe"
        case InfoLinkType.address: return "mappin.and.ellipse"
        case InfoLinkType.registration: return "square.and.pencil"
        default: return "link"
        }
    }

    static func iconName(for title: String) -> String {
        switch title {
        case Strings.Media.shared.YOUTUBE: return "play.rectangle.fill"
        case Strings.Media.shared.SPOTIFY: return SFSymbolCompat.icon(for: .spotify)
        case Strings.Media.shared.APPLE_PODCASTS: return SFSymbolCompat.icon(for: .applePodcasts)
        case Strings.Media.shared.FACEBOOK: return SFSymbolCompat.icon(for: .facebook)
        case Strings.Media.shared.INSTAGRAM: return "camera"
        case Strings.Media.shared.WEBSITE: return "globe"
        default: return "link"
        }
    }
}
