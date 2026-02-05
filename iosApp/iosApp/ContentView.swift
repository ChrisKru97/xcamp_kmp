import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            if appViewModel.isLoading {
                SplashView()
            } else {
                NavigationContainer()
            }
        }
        .background(Color.background.ignoresSafeArea())
    }
}

#Preview("Loaded state - LIMITED") {
    ContentView()
        .environmentObject({
            let vm = AppViewModel()
            vm.isLoading = false
            vm.appState = .limited
            return vm
        }())
        .environmentObject(AppRouter())
        .background(.background)
}

#Preview("Loaded state - ACTIVE_EVENT") {
    ContentView()
        .environmentObject({
            let vm = AppViewModel()
            vm.isLoading = false
            vm.appState = .activeEvent
            return vm
        }())
        .environmentObject(AppRouter())
        .background(.background)
}

#Preview("Loaded state - POST_EVENT") {
    ContentView()
        .environmentObject({
            let vm = AppViewModel()
            vm.isLoading = false
            vm.appState = .postEvent
            return vm
        }())
        .environmentObject(AppRouter())
        .background(.background)
}

#Preview("Loading state") {
    ContentView()
        .environmentObject(AppViewModel())
        .environmentObject(AppRouter())
        .background(.background)
}
