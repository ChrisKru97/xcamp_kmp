import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Domů")
            }
            .tag(0)
        }
    }
}
