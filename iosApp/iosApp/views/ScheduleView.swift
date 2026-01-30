import SwiftUI
import shared

// Typealias to avoid ambiguity with SwiftUI.Section
typealias ScheduleSection = shared.ExpandedSection

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var showingFilter = false

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
            }
        } else {
            contentView
        }
    }

    private var contentView: some View {
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

            if case .loaded = viewModel.state {
                filterFab
                    .padding(.trailing, Spacing.md)
                    .padding(.bottom, Spacing.md)
            }
        }
        .navigationTitle(Strings.Tabs.shared.SCHEDULE)
        .navigationBarTitleDisplayMode(.inline)
        .modifier(iOS16TabBarBackgroundModifier())
        .onAppear {
            viewModel.setRemoteConfigService(appViewModel.remoteConfigService)
        }
        .task {
            await viewModel.loadSections(service: appViewModel.scheduleService)
        }
        .sheet(isPresented: $showingFilter) {
            ScheduleFilterView(
                visibleTypes: $viewModel.visibleTypes,
                favoritesOnly: $viewModel.favoritesOnly
            )
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
                    Task {
                        await viewModel.loadDay(service: appViewModel.scheduleService, dayIndex: index)
                    }
                }
            )
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(sections, id: \.id) { section in
                        NavigationLink(destination: SectionDetailView(
                            section: section.base,
                            service: appViewModel.scheduleService,
                            onFavoriteToggled: {
                                Task {
                                    await viewModel.loadDay(service: appViewModel.scheduleService, dayIndex: viewModel.selectedDayIndex)
                                }
                            }
                        )) {
                            SectionListItem(section: section)
                                .equatable()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .refreshable {
                await viewModel.refreshSections(service: appViewModel.scheduleService)
            }
        }
    }

    private var dayNames: [String] {
        [
            Strings.ScheduleDays.shared.DAYS_SATURDAY,
            Strings.ScheduleDays.shared.DAYS_SUNDAY,
            Strings.ScheduleDays.shared.DAYS_MONDAY,
            Strings.ScheduleDays.shared.DAYS_TUESDAY,
            Strings.ScheduleDays.shared.DAYS_WEDNESDAY,
            Strings.ScheduleDays.shared.DAYS_THURSDAY,
            Strings.ScheduleDays.shared.DAYS_FRIDAY,
            Strings.ScheduleDays.shared.DAYS_SATURDAY
        ]
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Schedule.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .fillMaxSize()
        .background(Color.background)
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
                    await viewModel.loadSections(service: appViewModel.scheduleService)
                }
            }
            .buttonStyle(.bordered)
        }
        .fillMaxSize()
        .background(Color.background)
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
                    await viewModel.loadSections(service: appViewModel.scheduleService)
                }
            }
            .buttonStyle(.bordered)
        }
        .fillMaxSize()
        .background(Color.background)
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
