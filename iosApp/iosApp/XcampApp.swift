import SwiftUI
import Firebase
import shared

@main
struct XcampApp: App {
    @StateObject private var appViewModel = AppViewModel()

    init() {
        // Initialize Napier logging first so we can see debug output
        LoggerInitializerKt.initializeLogger()
        // Then initialize Firebase
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
