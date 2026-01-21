import SwiftUI

extension Color {
    // App-wide colors
    static let primary = Color("primary")
    static let secondary = Color("secondary")
    static let background = Color("background")

    // Schedule section type colors
    struct Section {
        static let main = Color(red: 0.45, green: 0.35, blue: 0.75) // Muted purple
        static let `internal` = Color(red: 0.30, green: 0.55, blue: 0.45) // Muted teal-green
        static let gospel = Color(red: 0.75, green: 0.40, blue: 0.55) // Muted rose
        static let food = Color(red: 0.70, green: 0.60, blue: 0.25) // Muted gold
        static let other = Color(red: 0.50, green: 0.50, blue: 0.50) // Neutral gray
    }
}