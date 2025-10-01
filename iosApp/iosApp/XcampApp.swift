import SwiftUI

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()

    init() {
        appViewModel.initializeApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}