import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300)
        }
    }
}

@available(iOS 18, *)
#Preview("Splash view", traits: .sizeThatFitsLayout) {
    SplashView()
}
