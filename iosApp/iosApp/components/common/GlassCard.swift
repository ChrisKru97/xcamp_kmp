import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var isScrollable: Bool = false

    var body: some View {
        Group {
            if isScrollable {
                // Scrollable variant: use material background directly
                // Much better performance than glass effect for many cards in lists
                content()
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(.ultraThinMaterial)
                    }
            } else {
                content()
                    .padding()
                    .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
            }
        }
    }
}

#Preview("Glass Card") {
    VStack(alignment: .leading, spacing: 20) {
        Text("Standalone Cards (full glass effect)").font(.headline)
        GlassCard {
            Text("Standalone Card")
        }.padding()
        GlassCard {
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.")
        }.padding()

        Divider()

        Text("Scrollable Cards (optimized material)").font(.headline)
        GlassCard(isScrollable: true) {
            Text("Scrollable Card - better performance")
        }.padding()
        GlassCard(isScrollable: true) {
            Text("Optimized for use in LazyVStack/LazyVGrid - uses ultraThinMaterial instead of expensive glass effect")
        }.padding()
    }
    .background(Color.background)
    .padding()
}
