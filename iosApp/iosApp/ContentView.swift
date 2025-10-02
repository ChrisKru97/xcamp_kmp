import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        let availableTabs = appViewModel.getAppConfigService()?.getAvailableTabs() ?? []

        TabView {
            ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                createTabView(for: tab)
                    .tag(index)
            }
        }
    }

    @ViewBuilder
    private func createTabView(for tab: AppTab) -> some View {
        switch tab {
            case .home:
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Domů")
                    }

            case .schedule:
                ScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Program")
                    }

            case .speakers:
                SpeakersView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("Řečníci")
                    }

            case .places:
                PlacesView()
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Místa")
                    }

            case .rating:
                RatingView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Hodnocení")
                    }

            case .media:
                MediaView()
                    .tabItem {
                        Image(systemName: "photo.fill")
                        Text("Média")
                    }

            case .info:
                InfoView()
                    .tabItem {
                        Image(systemName: "info.circle.fill")
                        Text("Info")
                    }
            default: EmptyView()
        }
    }
}
