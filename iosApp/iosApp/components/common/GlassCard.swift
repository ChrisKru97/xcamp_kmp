import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        if #available(iOS 26.0, *) {
            content()
                .padding()
                .glassEffect(.clear, in: .rect(cornerRadius: CornerRadius.medium))
        } else {
            content()
                .padding()
                .background(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.25),
                            .white.opacity(0.4)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 8)
        }
    }
}

@available(iOS 18, *)
#Preview("Glass Card", traits: .sizeThatFitsLayout) {
    VStack {
        GlassCard {
            Text("Test")
        }.padding()
        GlassCard {
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
        }.padding()
        GlassCard {
            VStack {
                Text("Test")
                Image("logo").resizable().scaledToFit().frame(height: 30)
            }
        }.padding()
        GlassCard {
            Image("logo")
        }.padding()
    }.background(Color.background)
}
