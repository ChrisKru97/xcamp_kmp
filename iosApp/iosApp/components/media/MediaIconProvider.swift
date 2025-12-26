import SwiftUI
import shared

enum MediaIconProvider {
    static func iconName(for mediaLink: MediaLink) -> String {
        iconName(for: mediaLink.title)
    }

    static func iconName(for title: String) -> String {
        switch title {
        case Strings.Media.shared.YOUTUBE: return "play.rectangle.fill"
        case Strings.Media.shared.SPOTIFY: return "music.note"
        case Strings.Media.shared.APPLE_PODCASTS: return "music.note"
        case Strings.Media.shared.FACEBOOK: return "book"
        case Strings.Media.shared.INSTAGRAM: return "camera"
        case Strings.Media.shared.WEBSITE: return "safari.fill"
        default: return "link"
        }
    }
}
