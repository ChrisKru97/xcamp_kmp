import SwiftUI
import shared

enum InfoIconProvider {
    static func iconName(for infoLink: InfoLink) -> String {
        iconName(for: infoLink.type)
    }

    static func iconName(for type: InfoLinkType) -> String {
        switch type {
        case InfoLinkType.phone: return "phone.fill"
        case InfoLinkType.email: return "envelope.fill"
        case InfoLinkType.web: return "safari.fill"
        case InfoLinkType.map: return "map.fill"
        case InfoLinkType.registration: return "square.and.pencil"
        default: return "link"
        }
    }
}
