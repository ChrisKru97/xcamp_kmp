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
                ScheduleFilterFab(
                    visibleTypes: viewModel.visibleTypes,
                    favoritesOnly: viewModel.favoritesOnly
                ) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showingFilter = true
                }
                .padding(.trailing, Spacing.lg)
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
                                await viewModel.loadDay(dayIndex: index)
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
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
                        .frame(width: 48, height: 48)
                        .contentShape(Circle())
                        .backport.glassEffect(
                            .regular,
                            in: Circle(),
                            fallbackBackground: .thinMaterial
                        )
                        .fabShadow()
                }
            }
        }
        .task {
            await viewModel.loadSections()
        }
        .sheet(isPresented: $showingFilter) {
            filterSheetContent
        }
    }

    private var filterSheetContent: some View {
        ScheduleFilterView(
            visibleTypes: $viewModel.visibleTypes,
            favoritesOnly: $viewModel.favoritesOnly
        )
        .backport.presentationDetents([.medium, .large])
    }

    private func scheduleContent(_ sections: [ScheduleSection]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(sections, id: \.uid) { section in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        router.push(section.base.uid, type: .section)
                    } label: {
                        SectionListItem(section: section)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshSections()
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
                    await viewModel.loadSections()
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
        Array(appViewModel.appConfigService.getEventDays())
            .map { $0.intValue }
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
