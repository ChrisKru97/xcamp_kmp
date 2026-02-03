import SwiftUI

/// Version-aware SF Symbol provider with iOS 15 fallbacks
enum SFSymbolCompat {
    static func icon(for key: IconKey) -> String {
        if #available(iOS 16.0, *) {
            return key.iOS16Symbol
        } else {
            return key.iOS15Fallback
        }
    }

    static func systemImage(_ key: IconKey) -> some View {
        Image(systemName: icon(for: key))
    }
}

enum IconKey {
    case filterButton
    case spotify
    case applePodcasts
    case facebook
    case homeTab
    case scheduleTab
    case speakersAndPlacesTab
    case ratingTab
    case mediaTab
    case aboutFestivalTab

    var iOS16Symbol: String {
        switch self {
        case .filterButton: return "line.3.horizontal.decrease.circle"
        case .spotify: return "wave.3.up.circle"
        case .applePodcasts: return "apple.podcasts.pages"
        case .facebook: return "f.cursive"
        case .homeTab: return "house.fill"
        case .scheduleTab: return "calendar"
        case .speakersAndPlacesTab: return "info.circle.text.page.fill"
        case .ratingTab: return "star.fill"
        case .mediaTab: return "photo.on.rectangle.angled.fill"
        case .aboutFestivalTab: return "questionmark.circle.fill"
        }
    }

    var iOS15Fallback: String {
        switch self {
        case .filterButton: return "ellipsis.circle"
        case .spotify: return "waveform"
        case .applePodcasts: return "podcast.fill"
        case .facebook: return "f.circle"
        case .homeTab: return "house.fill"
        case .scheduleTab: return "calendar"
        case .speakersAndPlacesTab: return "person.2.fill"
        case .ratingTab: return "star.fill"
        case .mediaTab: return "rectangle.stack.fill"
        case .aboutFestivalTab: return "questionmark.circle.fill"
        }
    }
}
