import SwiftUI
import NavigationBackport
import shared

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(availableTabs, id: \.self) { (tab: AppTab) in
                NBNavigationStack(path: pathForTab(tab)) {
                    rootView(for: tab)
                        .nbNavigationDestination(for: NavigationDestination.self) { destination in
                            destinationView(destination: destination)
                        }
                }
                .tabItem {
                    Label(label(for: tab), systemImage: tab.tabIcon)
                }
                .tag(tab)
            }
        }
        .tabViewStyle(.automatic)
        .injectServices()
    }

    private func pathForTab(_ tab: AppTab) -> Binding<NBNavigationPath> {
        Binding(
            get: { router.paths[tab] ?? NBNavigationPath() },
            set: { router.paths[tab] = $0 }
        )
    }

    @ViewBuilder
    private func destinationView(destination: NavigationDestination) -> some View {
        switch destination.type {
        case .section:
            SectionDetailView(sectionUid: destination.uid) {}
        case .speaker:
            SpeakerDetailView(speakerUid: destination.uid)
        case .place:
            PlaceDetailView(placeUid: destination.uid)
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func rootView(for tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .schedule: ScheduleView()
        case .speakersAndPlaces: SpeakersAndPlacesView()
        case .rating: RatingView()
        case .media: MediaView()
        case .aboutFestival: InfoView()
        default: EmptyView()
        }
    }

    private var availableTabs: [AppTab] {
        appViewModel.appConfigService.getAvailableTabs()
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

private struct ServiceInjectionModifier: ViewModifier {
    @EnvironmentObject var appViewModel: AppViewModel

    func body(content: Content) -> some View {
        content
            .environment(\.scheduleService, appViewModel.scheduleService)
            .environment(\.speakersService, appViewModel.speakersService)
            .environment(\.placesService, appViewModel.placesService)
    }
}

extension View {
    func injectServices() -> some View {
        modifier(ServiceInjectionModifier())
    }
}
