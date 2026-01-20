import SwiftUI
import shared

extension SectionType {
    var color: Color {
        switch self {
        case .main, .basic:
            return Color(red: 0.45, green: 0.35, blue: 0.75) // Muted purple
        case .internal:
            return Color(red: 0.30, green: 0.55, blue: 0.45) // Muted teal-green
        case .gospel:
            return Color(red: 0.75, green: 0.40, blue: 0.55) // Muted rose
        case .food:
            return Color(red: 0.70, green: 0.60, blue: 0.25) // Muted gold
        default:
            return Color(red: 0.50, green: 0.50, blue: 0.50) // Neutral gray
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
            return Strings.ScheduleSectionType.shared.SECTIONTYPE_MAIN
        case .internal:
            return Strings.ScheduleSectionType.shared.SECTIONTYPE_INTERNAL
        case .gospel:
            return Strings.ScheduleSectionType.shared.SECTIONTYPE_GOSPEL
        case .food:
            return Strings.ScheduleSectionType.shared.SECTIONTYPE_FOOD
        default:
            return Strings.ScheduleSectionType.shared.SECTIONTYPE_OTHER
        }
    }
}
