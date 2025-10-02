import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        var availableTabs = appViewModel.getAppConfigService()?.getAvailableTabs()
        TabView {
            availableTabs.map {
                
            }
            HomeView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Domů")
            }
            .tag(0)
        }
    }
}
