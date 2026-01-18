import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            let availableTabs = appViewModel.getAppConfigService().getAvailableTabs()

            TabView {
                ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                    createTabView(tab)
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
        }
    }

    @ViewBuilder
    private func createTabView(_ tab: AppTab) -> some View {
        switch tab {
            case .home:
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text(Strings.Tabs.shared.HOME)
                    }

            case .schedule:
                ScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(Strings.Tabs.shared.SCHEDULE)
                    }

            case .speakers:
                SpeakersView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text(Strings.Tabs.shared.SPEAKERS)
                    }

            case .places:
                PlacesView()
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text(Strings.Tabs.shared.PLACES)
                    }

            case .rating:
                RatingView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text(Strings.Tabs.shared.RATING)
                    }

            case .media:
                MediaView()
                    .tabItem {
                        Image(systemName: "photo.fill")
                        Text(Strings.Tabs.shared.MEDIA)
                    }

            case .info:
                InfoView()
                    .tabItem {
                        Image(systemName: "info.circle.fill")
                        Text(Strings.Tabs.shared.INFO)
                    }
            default: EmptyView()
        }
    }
}

#Preview("Loaded state") {
    ContentView()
        .environmentObject({
            let vm = AppViewModel()
            vm.isLoading = false
            return vm
        }())
        .background(.background)
}

#Preview("Loading state") {
    ContentView()
        .environmentObject(AppViewModel())
        .background(.background)
}
