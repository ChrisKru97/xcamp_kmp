import SwiftUI
import shared

extension SectionType {
    var color: Color {
        switch self {
        case .main, .basic:
            return .purple
        case .internal:
            return .green
        case .gospel:
            return .pink
        case .food:
            return .yellow
        default:
            return .gray
        }
    }

    var icon: String {
        switch self {
        case .main, .basic:
            return "star.fill"
        case .internal:
            return "person.3.fill"
        case .gospel:
            return "heart.fill"
        case .food:
            return "fork.knife"
        default:
            return "calendar"
        }
    }

    var label: String {
        switch self {
        case .main, .basic:
            return "Hlavní"
        case .internal:
            return "Interní"
        case .gospel:
            return "Gospel"
        case .food:
            return "Jídlo"
        default:
            return "Ostatní"
        }
    }
}
