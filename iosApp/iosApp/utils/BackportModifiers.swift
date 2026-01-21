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

    /// Bounce symbol effect for a Bool trigger
    @available(iOS 15.0, *)
    @ViewBuilder
    func bounceSymbol(trigger: Bool) -> some View {
        if #available(iOS 17.0, *) {
            content.symbolEffect(.bounce, value: trigger)
        } else {
            content
        }
    }

    /// Impact sensory feedback for a Bool trigger
    @available(iOS 15.0, *)
    @ViewBuilder
    func impactFeedback(trigger: Bool) -> some View {
        if #available(iOS 17.0, *) {
            content.sensoryFeedback(.impact(flexibility: .soft), trigger: trigger)
        } else {
            content
        }
    }
}

// MARK: - Common Layout Modifiers

extension View {
    /// Expands the view to fill the maximum available width with leading alignment
    /// Commonly used for list items and cards
    @ViewBuilder
    func fillMaxWidthLeading() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Expands the view to fill the maximum available width and height
    /// Commonly used for full-screen views
    @ViewBuilder
    func fillMaxSize() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
