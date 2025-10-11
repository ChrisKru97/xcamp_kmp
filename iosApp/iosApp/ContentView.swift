import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            let availableTabs = appViewModel.getAppConfigService().getAvailableTabs()

            if #available(iOS 18.0, *) {
                TabView {
                    ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                        createTabView(tab)
                            .tag(index)
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
            } else {
                TabView {
                    ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                        createTabView(tab)
                            .tag(index)
                    }
                }
            }
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

@available(iOS 18, *)
#Preview("Loaded state", traits: .sizeThatFitsLayout) {
    ContentView()
        .environmentObject({
            let vm = AppViewModel()
            vm.isLoading = false
            return vm
        }())
        .background(.background)
}

@available(iOS 18, *)
#Preview("Loading state", traits: .sizeThatFitsLayout) {
    ContentView()
        .environmentObject(AppViewModel())
        .background(.background)
}
