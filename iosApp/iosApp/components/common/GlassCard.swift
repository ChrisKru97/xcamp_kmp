import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding()
            .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
    }
}

#Preview("Glass Card") {
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
