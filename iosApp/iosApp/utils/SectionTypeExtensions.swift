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
            return Strings.Schedule.SectionType.shared.MAIN
        case .internal:
            return Strings.Schedule.SectionType.shared.INTERNAL
        case .gospel:
            return Strings.Schedule.SectionType.shared.GOSPEL
        case .food:
            return Strings.Schedule.SectionType.shared.FOOD
        default:
            return Strings.Schedule.SectionType.shared.OTHER
        }
    }
}
