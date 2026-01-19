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
