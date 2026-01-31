import SwiftUI

extension Color {
    // App-wide colors
    static let primary = Color("primary")
    static let secondary = Color("secondary")
    static let background = Color("background")

    // Schedule section type colors (with dark mode support)
    struct Section {
        static let main = Color("sectionMain")
        static let `internal` = Color("sectionInternal")
        static let gospel = Color("sectionGospel")
        static let food = Color("sectionFood")
        static let other = Color("sectionOther")
    }
}