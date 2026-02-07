import SwiftUI

struct Gradient {
    static let favorites = LinearGradient(
        colors: [Color.orange, Color.yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = LinearGradient(
        colors: [Color.accent, Color.accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
