import SwiftUI
import shared

struct ContentView: View {
    let greet = Greeting().greet()

    var body: some View {
        VStack(spacing: 20) {
            Text(greet)
                .font(.title)
                .multilineTextAlignment(.center)

            Text("XcamP Kotlin Multiplatform")
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}