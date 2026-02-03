import SwiftUI
import shared

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            mainContentView
        }
    }

    @ViewBuilder
    private var mainContentView: some View {
        let availableTabs = appViewModel.appConfigService.getAvailableTabs()

        TabView {
            tabView(for: .home) {
                HomeView()
            }

            if availableTabs.contains(.schedule) {
                tabView(for: .schedule) {
                    ScheduleView()
                }
            }

            if availableTabs.contains(.speakersAndPlaces) {
                tabView(for: .speakersAndPlaces) {
                    SpeakersAndPlacesView()
                }
            }

            if availableTabs.contains(.media) {
                tabView(for: .media) {
                    MediaView()
                }
            }

            if availableTabs.contains(.rating) {
                tabView(for: .rating) {
                    RatingView()
                }
            }

            if availableTabs.contains(.aboutFestival) {
                tabView(for: .aboutFestival) {
                    InfoView()
                }
            }
        }
        .tabViewStyle(.automatic)
    }

    @ViewBuilder
    private func tabView<Content: View>(for tab: AppTab, @ViewBuilder content: () -> Content) -> some View {
        content()
            .tabItem {
                Label(label(for: tab), systemImage: icon(for: tab))
            }
            .tag(tab)
    }

    private func icon(for tab: AppTab) -> String {
        switch tab {
        case .home: return SFSymbolCompat.icon(for: .homeTab)
        case .schedule: return SFSymbolCompat.icon(for: .scheduleTab)
        case .speakersAndPlaces: return SFSymbolCompat.icon(for: .speakersAndPlacesTab)
        case .rating: return SFSymbolCompat.icon(for: .ratingTab)
        case .media: return SFSymbolCompat.icon(for: .mediaTab)
        case .aboutFestival: return SFSymbolCompat.icon(for: .aboutFestivalTab)
        default: return "circle.fill"
        }
    }

    private func label(for tab: AppTab) -> String {
        switch tab {
        case .home: return Strings.Tabs.shared.HOME
        case .schedule: return Strings.Tabs.shared.SCHEDULE
        case .speakersAndPlaces: return Strings.Tabs.shared.SPEAKERS_AND_PLACES
        case .rating: return Strings.Tabs.shared.RATING
        case .media: return Strings.Tabs.shared.MEDIA
        case .aboutFestival: return Strings.Tabs.shared.ABOUT_FESTIVAL
        default: return ""
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
        .background(.background)
}

#Preview("Loading state") {
    ContentView()
        .environmentObject(AppViewModel())
        .background(.background)
}
