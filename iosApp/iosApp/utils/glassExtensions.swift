import SwiftUI

extension View {
    @ViewBuilder func withDynamicGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .rect(cornerRadius: 10))
        } else {
            self
        }
    }
}
