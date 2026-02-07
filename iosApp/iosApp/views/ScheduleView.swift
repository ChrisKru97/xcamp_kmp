import SwiftUI
import shared

// Typealias to avoid ambiguity with SwiftUI.Section
typealias ScheduleSection = shared.ExpandedSection

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var showingFilter = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded:
                scheduleContent(viewModel.filteredSections)
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
            SFSymbolCompat.systemImage(.filterButton)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background {
                    glassBackground
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
                .backport.glassEffect(BackportGlass.regular, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            Color.clear
        } else {
            Rectangle().fill(.thinMaterial)
        }
    }

    private func scheduleContent(_ sections: [ScheduleSection]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(sections, id: \.uid) { section in
                    Button {
                        router.push(section.base.uid)
                    } label: {
                        SectionListItem(section: section)
                            .equatable()
                    }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
