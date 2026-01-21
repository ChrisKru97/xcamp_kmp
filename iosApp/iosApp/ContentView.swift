import SwiftUI
import shared
import OSLog

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTabIndex: Int = 0
    @State private var previousTabIndex: Int = 0
    @State private var showingMorePopover = false
    @State private var isRevertingFromMoreTab = false

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "ContentView")

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            // Use the appState from AppViewModel which was set during initialization
            let availableTabs = appViewModel.getAvailableTabsForCurrentState()

            TabView(selection: $selectedTabIndex) {
                ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                    createTabView(tab, availableTabs: availableTabs)
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
            .tint(.accentColor)
            .onChange(of: selectedTabIndex) { newValue in
                // Skip if we're reverting from More tab (don't update previousTabIndex)
                if isRevertingFromMoreTab {
                    return
                }

                // Check if the newly selected tab is the "More" tab
                let moreTab = availableTabs.firstIndex { $0 == .more }
                if newValue == moreTab {
                    // Show the popover instead of navigating
                    showingMorePopover = true
                    // Don't actually navigate to the More tab - stay on previous tab
                    isRevertingFromMoreTab = true
                    selectedTabIndex = previousTabIndex
                    // Reset flag after the state update completes
                    Task { @MainActor in
                        isRevertingFromMoreTab = false
                    }
                } else {
                    // Update previous index for non-More tabs
                    previousTabIndex = newValue
                }
            }
            .confirmationDialog(
                Strings.Common.shared.MORE_OPTIONS,
                isPresented: $showingMorePopover,
                titleVisibility: .visible
            ) {
                Button(Strings.Tabs.shared.MEDIA) {
                    let availableTabs = appViewModel.getAvailableTabsForCurrentState()
                    if let mediaIndex = availableTabs.firstIndex(of: .media) {
                        selectedTabIndex = mediaIndex
                    }
                }

                Button(Strings.Tabs.shared.INFO) {
                    let availableTabs = appViewModel.getAvailableTabsForCurrentState()
                    if let infoIndex = availableTabs.firstIndex(of: .info) {
                        selectedTabIndex = infoIndex
                    }
                }

                Button(Strings.Common.shared.CANCEL, role: .cancel) { }
            }
        }
    }

    @ViewBuilder
    private func createTabView(_ tab: AppTab, availableTabs: [AppTab]) -> some View {
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

            case .more:
                // More tab is handled via popover - this is just a placeholder
                EmptyView()
                    .tabItem {
                        Image(systemName: "ellipsis.circle.fill")
                        Text(Strings.Tabs.shared.MORE)
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
