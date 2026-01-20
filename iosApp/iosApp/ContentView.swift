import SwiftUI
import shared
import OSLog

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTabIndex: Int = 0

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "ContentView")

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            // Use the appState from AppViewModel which was set during initialization
            let availableTabs = appViewModel.getAvailableTabsForCurrentState()

            TabView(selection: $selectedTabIndex) {
                ForEach(Array(availableTabs.enumerated()), id: \.element) { index, tab in
                    createTabView(tab, availableTabs: availableTabs, selectedIndex: $selectedTabIndex)
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
        }
    }

    @ViewBuilder
    private func createTabView(_ tab: AppTab, availableTabs: [AppTab], selectedIndex: Binding<Int>) -> some View {
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
                MorePopupView(selectedTabIndex: selectedIndex)
                    .tabItem {
                        Image(systemName: "ellipsis.circle.fill")
                        Text("More")
                    }
            default: EmptyView()
        }
    }
}

/// A view that displays a popup menu with Media and Info options
/// Used when tabs would overflow on smaller devices
/// Shows a popup menu immediately when the More tab is selected
struct MorePopupView: View {
    @State private var activeView: MoreViewOption?
    @Binding var selectedTabIndex: Int

    enum MoreViewOption: String, Identifiable {
        case media
        case info
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            // Background
            Color.background.ignoresSafeArea()

            // Popup menu
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: Spacing.sm) {
                    // Media option
                    Button(action: {
                        activeView = .media
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.accentColor)
                            Text(Strings.Tabs.shared.MEDIA)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Info option
                    Button(action: {
                        activeView = .info
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.accentColor)
                            Text(Strings.Tabs.shared.INFO)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Close button
                    Button(action: {
                        // Return to Home tab
                        selectedTabIndex = 0
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                            Text("Close")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(radius: 20)
                )
                .padding(Spacing.md)
            }
        }
        .onAppear {
            // Auto-show the popup when this view appears
            activeView = nil
        }
        .sheet(item: $activeView) { option in
            Group {
                switch option {
                case .media:
                    MediaView()
                case .info:
                    InfoView()
                }
            }
            .onDisappear {
                // When sheet is dismissed, return to Home tab
                selectedTabIndex = 0
            }
        }
    }
}

#Preview("More Popup View") {
    MorePopupView(selectedTabIndex: .constant(0))
        .preferredColorScheme(.dark)
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
