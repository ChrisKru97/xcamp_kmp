import SwiftUI
import shared

enum MediaIconProvider {
    static func iconName(for mediaLink: MediaLink) -> String {
        iconName(for: mediaLink.title)
    }

    static func iconName(for title: String) -> String {
        switch title {
        case "YouTube": return "play.rectangle.fill"
        case "Spotify": return "music.note"
        case "Apple Podcasts": return "music.note"
        case "Facebook": return "book"
        case "Instagram": return "camera"
        case "Website": return "safari.fill"
        default: return "link"
        }
    }
}
