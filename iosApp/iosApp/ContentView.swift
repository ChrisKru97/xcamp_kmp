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
                        Text(StringsKt().tabs.home)
                    }

            case .schedule:
                ScheduleView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(StringsKt().tabs.schedule)
                    }

            case .speakers:
                SpeakersView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text(StringsKt().tabs.speakers)
                    }

            case .places:
                PlacesView()
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text(StringsKt().tabs.places)
                    }

            case .rating:
                RatingView()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text(StringsKt().tabs.rating)
                    }

            case .media:
                MediaView()
                    .tabItem {
                        Image(systemName: "photo.fill")
                        Text(StringsKt().tabs.media)
                    }

            case .info:
                InfoView()
                    .tabItem {
                        Image(systemName: "info.circle.fill")
                        Text(StringsKt().tabs.info)
                    }
            default: EmptyView()
        }
    }
}
