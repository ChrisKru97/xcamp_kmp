import SwiftUI
import UIKit

// MARK: - ScaleButtonStyle

struct ScaleButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.95
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light

    @State private var hasTriggeredHaptic = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                triggerHapticIfNeeded(wasPressed: !newValue)
            }
    }

    private func triggerHapticIfNeeded(wasPressed: Bool) {
        if wasPressed && !hasTriggeredHaptic {
            hasTriggeredHaptic = true
            UIImpactFeedbackGenerator(style: hapticStyle).impactOccurred()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                hasTriggeredHaptic = false
            }
        }
    }
}

extension View {
    func scaleButton(haptic: UIImpactFeedbackGenerator.FeedbackStyle = .light, scale: CGFloat = 0.95) -> some View {
        self.buttonStyle(ScaleButtonStyle(scaleAmount: scale, hapticStyle: haptic))
    }
}

// MARK: - Glass Button

extension View {
    @ViewBuilder
    func glassButton() -> some View {
        self
            .backport.glassEffect(
                in: RoundedRectangle(cornerRadius: 12),
                fallbackBackground: .thinMaterial
            )
            .scaleButton()
            .cardShadow()
    }
}
