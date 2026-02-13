import SwiftUI

enum SFSymbolCompat {
    static func icon(for key: IconKey) -> String {
        if #available(iOS 16.0, *) {
            return key.iOS16Symbol
        } else {
            return key.iOS15Fallback
        }
    }

}

enum IconKey {
    case spotify
    case applePodcasts
    case facebook

    var iOS16Symbol: String {
        switch self {
        case .spotify: return "wave.3.up.circle"
        case .applePodcasts: return "apple.podcasts.pages"
        case .facebook: return "f.cursive"
        }
    }

    var iOS15Fallback: String {
        switch self {
        case .spotify: return "waveform"
        case .applePodcasts: return "podcast.fill"
        case .facebook: return "f.circle"
        }
    }
}
