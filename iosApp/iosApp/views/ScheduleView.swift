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
        EmptyView()
                .switchingContent(viewModel.state) { sections, isStale in
                    scheduleContent(sections, isStale: isStale)
                } error: { error in
                    ErrorView(error: error) {
                        await viewModel.loadSections()
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

                    Divider()

                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showingFilter = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(Strings.Schedule.shared.FILTER_MENU)
                        }
                    }
                } label: {
                    Image(systemName: "calendar")
                        .imageScale(.medium)
                        .foregroundStyle(.primary)
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
            filterState: $viewModel.filterState
        )
        .backport.presentationDetents([.medium, .large])
    }

    private func scheduleContent(_ sections: [ScheduleSection], isStale: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                if isStale {
                    StaleDataBanner()
                }

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
