import SwiftUI
import NavigationBackport
import shared

struct NavigationContainer: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(availableTabs, id: \.self) { (tab: AppTab) in
                navigationStack(for: tab)
                    .tabItem {
                        tabLabel(for: tab)
                    }
                    .tag(tab)
            }
        }
        .tabViewStyle(.automatic)
        .animation(.easeInOut(duration: 0.2), value: router.selectedTab) // TODO do we need it? try it without it
        .onAppear {
            configureTabBarAppearance()
        }
        .onChange(of: colorScheme) {
            configureTabBarAppearance()
        }
        .onChange(of: router.selectedTab) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToSection)) { notification in
            guard let userInfo = notification.userInfo,
                  let sectionUid = userInfo["sectionUid"] as? String else { return }

            router.selectedTab = .schedule
            router.push(sectionUid, type: .section)
        }
    }

    @ViewBuilder
    private func navigationStack(for tab: AppTab) -> some View {
        NBNavigationStack(path: pathForTab(tab)) {
            rootView(for: tab)
                .nbNavigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(destination: destination)
                }
        }
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
            SectionDetailView(sectionUid: destination.uid)
        case .speaker:
            SpeakerDetailView(speakerUid: destination.uid)
        case .place:
            PlaceDetailView(placeUid: destination.uid)
        case .notificationSettings:
            NotificationSettingsView()
        case .none:
            EmptyView()
        }
    }

    @ViewBuilder
    private func rootView(for tab: AppTab) -> some View {
        ZStack {
            MeshGradientBackground()

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

    @ViewBuilder
    private func tabLabel(for tab: AppTab) -> some View {
        // TODO check if it's necessary
        if #available(iOS 17.0, *) {
            Label(label(for: tab), systemImage: tab.tabIcon)
                .symbolEffect(.bounce, options: .repeat(1), value: router.selectedTab == tab)
        } else {
            Label(label(for: tab), systemImage: tab.tabIcon)
        }
    }

    @MainActor
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        appearance.shadowColor = colorScheme == .dark
            ? Color.TabBar.shadowDark
            : Color.TabBar.shadowLight

        if colorScheme == .dark {
            appearance.backgroundColor = Color.TabBar.backgroundDark
        } else {
            appearance.backgroundColor = Color.TabBar.backgroundLight
        }

        configureTabIconColors(for: appearance)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func configureTabIconColors(for appearance: UITabBarAppearance) {
        if colorScheme == .dark {
            appearance.stackedLayoutAppearance.selected.iconColor = Color.TabBar.iconSelectedDark
            appearance.stackedLayoutAppearance.normal.iconColor = Color.TabBar.iconNormalDark
        } else {
            appearance.stackedLayoutAppearance.selected.iconColor = Color.TabBar.iconSelectedLight
            appearance.stackedLayoutAppearance.normal.iconColor = Color.TabBar.iconNormalLight
        }

        appearance.inlineLayoutAppearance.selected.iconColor = appearance.stackedLayoutAppearance.selected.iconColor
        appearance.inlineLayoutAppearance.normal.iconColor = appearance.stackedLayoutAppearance.normal.iconColor
    }
}
