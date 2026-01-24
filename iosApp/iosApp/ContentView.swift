import SwiftUI
import shared
import OSLog

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab: AppTab = .home
    @State private var showingMorePopover = false

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "ContentView")

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            mainContentView
        }
    }

    // MARK: - Computed Properties for View Optimization

    private var availableTabs: [AppTab] {
        appViewModel.getAvailableTabsForCurrentState()
    }

    // Determine if we need the "More" overflow tab
    // iOS shows 5 tabs max before moving overflow to "More" list
    private var needsMoreTab: Bool {
        availableTabs.count > 5
    }

    // Get tabs that should be visible in the tab bar (excluding overflow)
    private var visibleTabs: [AppTab] {
        if needsMoreTab {
            // First 5 tabs + More tab
            return Array(availableTabs.prefix(5)) + [.more]
        } else {
            return availableTabs
        }
    }

    // Get overflow tabs that go in the More menu
    private var overflowTabs: [AppTab] {
        if needsMoreTab {
            return Array(availableTabs.dropFirst(5))
        } else {
            return []
        }
    }

    @ViewBuilder
    private var mainContentView: some View {
        TabView(selection: $selectedTab) {
            // All tab views (needed for navigation regardless of visibility)
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

            if availableTabs.contains(.rating) {
                tabView(for: .rating) {
                    RatingView()
                }
            }

            if availableTabs.contains(.media) {
                tabView(for: .media) {
                    MediaView()
                }
            }

            if availableTabs.contains(.aboutFestival) {
                tabView(for: .aboutFestival) {
                    InfoView()
                }
            }

            // More tab (only visible when needed)
            if needsMoreTab {
                Color.clear
                    .tabItem {
                        Label(Strings.Tabs.shared.MORE, systemImage: "ellipsis")
                    }
                    .tag(AppTab.more)
            }
        }
        .tabViewStyle(.automatic)
        .onChange(of: selectedTab) { newValue in
            // Handle "More" tab tap - show popover instead of navigating
            if newValue == .more {
                showingMorePopover = true
            }
        }
        .popover(isPresented: $showingMorePopover) {
            MoreOptionsMenu(
                overflowTabs: overflowTabs,
                selectedTab: $selectedTab
            )
        }
    }

    // Helper to create a tab view with proper labeling
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
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .speakersAndPlaces: return "info.circle.fill"
        case .rating: return "star.fill"
        case .media: return "photo.fill"
        case .aboutFestival: return "questionmark.circle.fill"
        case .more: return "ellipsis"
        default: return "circle"
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
        case .more: return Strings.Tabs.shared.MORE
        default: return ""
        }
    }
}

// MARK: - More Options Menu

struct MoreOptionsMenu: View {
    let overflowTabs: [AppTab]
    @Binding var selectedTab: AppTab
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(overflowTabs.enumerated()), id: \.offset) { index, tab in
                if index > 0 {
                    Divider()
                }

                Button {
                    selectedTab = tab
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: icon(for: tab))
                        Text(label(for: tab))
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .frame(width: 200)
    }

    private func icon(for tab: AppTab) -> String {
        switch tab {
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .speakersAndPlaces: return "info.circle.fill"
        case .rating: return "star.fill"
        case .media: return "photo.fill"
        case .aboutFestival: return "questionmark.circle.fill"
        case .more: return "ellipsis"
        default: return "circle"
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
        case .more: return Strings.Tabs.shared.MORE
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
