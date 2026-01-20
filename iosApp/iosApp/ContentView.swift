import SwiftUI
import shared
import OSLog

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    private let logger = Logger(subsystem: "com.krutsche.xcamp", category: "ContentView")

    var body: some View {
        if appViewModel.isLoading {
            SplashView()
        } else {
            // Use the appState from AppViewModel which was set during initialization
            let availableTabs = appViewModel.getAvailableTabsForCurrentState()

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

            case .more:
                MoreTabView()
                    .tabItem {
                        Image(systemName: "ellipsis.circle.fill")
                        Text("More")
                    }
            default: EmptyView()
        }
    }
}

/// A view that displays a menu with Media and Info options
/// Used when tabs would overflow on smaller devices
struct MoreTabView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    // Media option
                    NavigationLink(destination: MediaView()) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 50)

                            Text(Strings.Tabs.shared.MEDIA)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Info option
                    NavigationLink(destination: InfoView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 50)

                            Text(Strings.Tabs.shared.INFO)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("More")
        }
    }
}

#Preview("More Tab View") {
    MoreTabView()
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
