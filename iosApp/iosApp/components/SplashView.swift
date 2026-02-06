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

#Preview("Splash view") {
    SplashView()
}
