import SwiftUI
import shared

// Typealias to avoid ambiguity with SwiftUI.Section
typealias ScheduleSection = shared.ExpandedSection

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var showingFilter = false
    @State private var showingDayPicker = false

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
            case .error(let message):
                errorView(message)
            }

            if case .loaded = viewModel.state {
                filterFab
                    .padding(.trailing, Spacing.md)
                    .padding(.bottom, Spacing.md)
            }
        }
        .navigationTitle(dayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(Array(dayNames.enumerated()), id: \.offset) { index, dayName in
                        Button {
                            viewModel.selectDay(index: index)
                            Task {
                                await viewModel.loadDay(service: appViewModel.scheduleService, dayIndex: index)
                            }
                        } label: {
                            HStack {
                                Text(dayNameWithDate(dayName, index: index))
                                if index == viewModel.selectedDayIndex {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "calendar")
                }
            }
        }
        .modifier(iOS16TabBarBackgroundModifier())
        .onAppear {
            viewModel.setRemoteConfigService(appViewModel.remoteConfigService)
        }
        .task {
            await viewModel.loadSections(service: appViewModel.scheduleService)
        }
        .sheet(isPresented: $showingFilter) {
            if #available(iOS 16.4, *) {
                ScheduleFilterView(
                    visibleTypes: $viewModel.visibleTypes,
                    favoritesOnly: $viewModel.favoritesOnly
                )
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
            } else if #available(iOS 16.0, *) {
                ScheduleFilterView(
                    visibleTypes: $viewModel.visibleTypes,
                    favoritesOnly: $viewModel.favoritesOnly
                )
                .presentationDragIndicator(.visible)
            } else {
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
                .foregroundColor(.primary)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .contentShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func scheduleContent(_ sections: [ScheduleSection]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(sections, id: \.uid) { section in
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

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(Strings.Schedule.shared.ERROR_TITLE)
                .font(.headline)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
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

    private var dayTitle: String {
        let dayName = dayNames[viewModel.selectedDayIndex]
        return dayNameWithDate(dayName, index: viewModel.selectedDayIndex)
    }

    private func dayNameWithDate(_ name: String, index: Int) -> String {
        "\(eventDays[index]). \(name)"
    }

    private var eventDays: [Int] {
        let dateString = appViewModel.remoteConfigService.getStartDate()
        guard let date = parseStartDate(dateString) else {
            return [18, 19, 20, 21, 22, 23, 24, 25]
        }
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: date)
        return (0..<8).map { startDay + $0 }
    }

    private func parseStartDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
