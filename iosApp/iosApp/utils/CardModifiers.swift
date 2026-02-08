import SwiftUI

extension View {
    @ViewBuilder
    func card() -> some View {
        self.backport.glassEffect(in: RoundedRectangle(cornerRadius: 12), fallbackBackground: .thinMaterial).cardShadow()
    }

    @ViewBuilder
    func cardShadow() -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            self.shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
        }
    }

    @ViewBuilder
    func fabShadow() -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            self.shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }

    @ViewBuilder
    func circularFab(
        glassEffect: BackportGlass = .regular,
        fallbackBackground: AnyShapeStyle = AnyShapeStyle(.thinMaterial)
    ) -> some View {
        self
            .frame(width: 48, height: 48)
            .contentShape(Circle())
            .backport.glassEffect(glassEffect, in: Circle(), fallbackBackground: fallbackBackground)
            .fabShadow()
    }
}
