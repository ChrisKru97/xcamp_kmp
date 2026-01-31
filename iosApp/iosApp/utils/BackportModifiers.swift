import SwiftUI

// MARK: - Backport Namespace
struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

// MARK: - Backport Modifiers
extension Backport where Content: View {
    /// glassEffect backport (iOS 26+ → iOS 15+ fallback)
    @ViewBuilder
    func glassEffect(in shape: some InsettableShape) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.clear, in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }

    /// Bounce symbol effect (iOS 17+ → no-op fallback)
    @ViewBuilder
    func bounceSymbol(trigger: Bool) -> some View {
        if #available(iOS 17.0, *) {
            content.symbolEffect(.bounce, value: trigger)
        } else {
            content
        }
    }

    /// Impact sensory feedback (iOS 17+ → no-op fallback)
    @ViewBuilder
    func impactFeedback(trigger: Bool) -> some View {
        if #available(iOS 17.0, *) {
            content.sensoryFeedback(.impact(flexibility: .soft), trigger: trigger)
        } else {
            content
        }
    }
}

// MARK: - iOS 16+ Toolbar Modifiers

extension View {
    /// Shows a visible blurred background on the tab bar (iOS 16+)
    func tabBarBackground() -> some View {
        modifier(iOS16TabBarBackgroundModifier())
    }

    /// Hides the tab bar (iOS 16+)
    func hideTabBar() -> some View {
        modifier(iOS16TabBarHiddenModifier())
    }
}

private struct iOS16TabBarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbarBackground(.regularMaterial, for: .tabBar)
        } else {
            content
        }
    }
}

private struct iOS16TabBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .tabBar)
        } else {
            content
        }
    }
}
