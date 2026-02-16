import SwiftUI
import UIKit

extension Color {
    static let primary = Color("primary")
    static let secondary = Color("secondary")
    static let background = Color("background")
    static let accent = Color("designAccent")
    static let accentSecondary = Color("designAccentSecondary")

    struct Section {
        static let main = Color("sectionMain")
        static let `internal` = Color("sectionInternal")
        static let gospel = Color("sectionGospel")
        static let food = Color("sectionFood")
        static let other = Color("sectionOther")
    }

    struct TabBar {
        static let shadowLight = UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 0.15)
        static let shadowDark = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.10)

        static let backgroundLight = UIColor(red: 0.73, green: 0.89, blue: 0.91, alpha: 0.50)
        static let backgroundDark = UIColor(red: 0.07, green: 0.27, blue: 0.48, alpha: 0.85)

        static let iconSelectedLight = UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 1.0)
        static let iconNormalLight = UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 0.50)

        static let iconSelectedDark = UIColor(red: 0.65, green: 0.95, blue: 1.0, alpha: 1.0)
        static let iconNormalDark = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.70)
    }
}

extension UIColor {
    static let tabBarBackground = UIColor(Color("tabBarBackground"))    
}
