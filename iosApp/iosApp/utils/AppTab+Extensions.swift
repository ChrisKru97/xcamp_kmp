import shared

extension AppTab {
    var tabIcon: String {
        if #available(iOS 16.0, *) {
            return iOS16Symbol
        } else {
            return iOS15Fallback
        }
    }

    private var iOS16Symbol: String {
        switch self {
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .speakersAndPlaces: return "info.circle.text.page.fill"
        case .rating: return "star.fill"
        case .media: return "photo.on.rectangle.angled.fill"
        case .aboutFestival: return "questionmark.circle.fill"
        default: return "circle.fill"
        }
    }

    private var iOS15Fallback: String {
        switch self {
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .speakersAndPlaces: return "person.2.fill"
        case .rating: return "star.fill"
        case .media: return "rectangle.stack.fill"
        case .aboutFestival: return "questionmark.circle.fill"
        default: return "circle.fill"
        }
    }
}
