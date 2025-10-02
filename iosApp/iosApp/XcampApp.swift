import SwiftUI

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .onAppear {
                    appViewModel.initializeApp()
                }
        }
    }
}
