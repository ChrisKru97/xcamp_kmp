import SwiftUI
import shared

// Typealias to avoid ambiguity with SwiftUI.Section
typealias ScheduleSection = shared.Section

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var showingFilter = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.background.ignoresSafeArea()

                switch viewModel.state {
                case .loading:
                    loadingView
                case .loaded:
                    if viewModel.filteredSections.isEmpty {
                        emptyView
                    } else {
                        scheduleContent(viewModel.filteredSections)
                    }
                case .error:
                    errorView
                }

                // Filter FAB
                if case .loaded = viewModel.state {
                    filterFab
                        .padding(.trailing, Spacing.md)
                        .padding(.bottom, Spacing.md)
                }
            }
            .navigationTitle(Strings.Tabs.shared.SCHEDULE)
            .task {
                await viewModel.loadSections(service: appViewModel.getScheduleService())
            }
            .sheet(isPresented: $showingFilter) {
                ScheduleFilterView(
                    visibleTypes: $viewModel.visibleTypes,
                    favoritesOnly: $viewModel.favoritesOnly
                )
            }
        }
    }

    private var filterFab: some View {
        Button(action: { showingFilter = true }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(Color.secondary.opacity(0.8))
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }

    private func scheduleContent(_ sections: [ScheduleSection]) -> some View {
        VStack(spacing: 0) {
            ScheduleDayTab(
                selectedDayIndex: viewModel.selectedDayIndex,
                dayNames: dayNames,
                onDaySelected: { index in
                    viewModel.selectDay(index: index)
                }
            )
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(sections, id: \.id) { section in
                        NavigationLink(destination: SectionDetailView(section: section)) {
                            SectionListItem(section: section)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .refreshable {
                await viewModel.refreshSections(service: appViewModel.getScheduleService())
            }
        }
    }

    private var dayNames: [String] {
        [
            Strings.ScheduleDays.shared.DAYS_SATURDAY,  // Day 1
            Strings.ScheduleDays.shared.DAYS_SUNDAY,    // Day 2
            Strings.ScheduleDays.shared.DAYS_MONDAY,    // Day 3
            Strings.ScheduleDays.shared.DAYS_TUESDAY,   // Day 4
            Strings.ScheduleDays.shared.DAYS_WEDNESDAY, // Day 5
            Strings.ScheduleDays.shared.DAYS_THURSDAY,  // Day 6
            Strings.ScheduleDays.shared.DAYS_FRIDAY,    // Day 7
            Strings.ScheduleDays.shared.DAYS_SATURDAY   // Day 8
        ]
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Schedule.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "calendar")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(Strings.Schedule.shared.EMPTY_TITLE)
                .font(.headline)
                .foregroundColor(.secondary)
            Button(Strings.Schedule.shared.RETRY) {
                Task {
                    await viewModel.loadSections(service: appViewModel.getScheduleService())
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(Strings.Schedule.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Schedule.shared.RETRY) {
                Task {
                    await viewModel.loadSections(service: appViewModel.getScheduleService())
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
