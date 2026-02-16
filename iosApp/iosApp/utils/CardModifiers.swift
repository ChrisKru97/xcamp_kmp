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
}
