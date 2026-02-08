import SwiftUI

struct SplashView: View {
    var body: some View {
        Group {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.background)
    }
}

#Preview("Splash view") {
    SplashView()
}
