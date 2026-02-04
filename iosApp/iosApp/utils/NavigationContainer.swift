import SwiftUI
import NavigationBackport
import shared

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(availableTabs, id: \.self) { tab in
                NBNavigationStack(path: pathForTab(tab)) {
                    rootView(for: tab)
                        .nbNavigationDestination(for: String.self) { uid in
                            destinationView(uid: uid)
                        }
                }
                .tabItem {
                    Label(label(for: tab), systemImage: icon(for: tab))
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
    private func destinationView(uid: String) -> some View {
        switch router.selectedTab {
        case .schedule:
            SectionDetailView(sectionUid: uid) {}
        case .speakersAndPlaces:
            SpeakerDetailView(speakerUid: uid)
        case .rating, .media, .aboutFestival, .home:
            EmptyView()
        default:
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

private struct ServiceInjectionView<Content: View>: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let content: Content

    var body: some View {
        content
            .environment(\.scheduleService, appViewModel.scheduleService)
            .environment(\.speakersService, appViewModel.speakersService)
            .environment(\.placesService, appViewModel.placesService)
    }
}

extension View {
    func injectServices() -> some View {
        ServiceInjectionView(content: self)
    }
}
