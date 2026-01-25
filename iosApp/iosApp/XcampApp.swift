import SwiftUI
import Firebase
import FirebaseCore
import shared
import Kingfisher

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()

    init() {
        FirebaseApp.configure()
    }

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
