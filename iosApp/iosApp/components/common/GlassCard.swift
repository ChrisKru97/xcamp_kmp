import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    private let cornerRadius: CGFloat = 12

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                if #available(iOS 26.0, *) {
                    Color.clear
                } else {
                    Rectangle().fill(.thinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
            .backport.glassEffect(BackportGlass.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Previews

#Preview("GlassCard - Default") {
    ZStack {
        Color.background.ignoresSafeArea()
        GlassCard {
            HStack {
                Image(systemName: "heart.fill")
                Text("Default card")
            }
        }
        .padding()
    }
}

#Preview("GlassCard - Custom Padding") {
    ZStack {
        Color.background.ignoresSafeArea()
        GlassCard(padding: 8) {
            HStack {
                Image(systemName: "star.fill")
                Text("Custom padding (8pt)")
            }
        }
        .padding()
    }
}

#Preview("GlassCard - Dark Mode") {
    ZStack {
        Color.background.ignoresSafeArea()
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Information")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("Glass card with thinMaterial fallback on iOS 15-18")
                    .font(.body)
            }
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
