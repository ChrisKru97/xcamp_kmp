import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.isLoading {
                SplashView()
            } else {
                NavigationContainer()
            }
        }
        .alert(Strings.ForceUpdate.shared.TITLE, isPresented: $appViewModel.showForceUpdateAlert) {
            Button(Strings.ForceUpdate.shared.UPDATE_NOW) {
                openAppStore()
            }
            Button(Strings.ForceUpdate.shared.MAYBE_LATER, role: .cancel) {
                let forceUpdateVersion = appViewModel.remoteConfigService.getForceUpdateVersion()
                AppPreferences.setDismissedForceUpdateVersion(version: forceUpdateVersion)
                appViewModel.showForceUpdateWarning = true
            }
        } message: {
            Text(Strings.ForceUpdate.shared.MESSAGE)
        }
        .alert(Strings.ForceUpdate.shared.WARNING_TITLE, isPresented: $appViewModel.showForceUpdateWarning) {
            Button(Strings.ForceUpdate.shared.WARNING_OK) {
                // User acknowledges warning, continues using app
            }
        } message: {
            Text(Strings.ForceUpdate.shared.WARNING_MESSAGE)
        }
    }

    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/cz/app/xcamp/id6448851641") {
            UIApplication.shared.open(url)
        }
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
