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
            Strings.Schedule.Days.shared.SATURDAY,  // Day 1
            Strings.Schedule.Days.shared.SUNDAY,    // Day 2
            Strings.Schedule.Days.shared.MONDAY,    // Day 3
            Strings.Schedule.Days.shared.TUESDAY,   // Day 4
            Strings.Schedule.Days.shared.WEDNESDAY, // Day 5
            Strings.Schedule.Days.shared.THURSDAY,  // Day 6
            Strings.Schedule.Days.shared.FRIDAY,    // Day 7
            Strings.Schedule.Days.shared.SATURDAY   // Day 8
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

// MARK: - ViewModel

@MainActor
class ScheduleViewModel: ObservableObject {
    @Published private(set) var state: ScheduleState = .loading
    @Published private(set) var selectedDayIndex: Int = 0
    @Published var visibleTypes: Set<SectionType> = Set([
        .main, .internal, .gospel, .food
    ])
    @Published var favoritesOnly: Bool = false

    private var allSections: [ScheduleSection] = []

    var filteredSections: [ScheduleSection] {
        guard case .loaded(let sections) = state else {
            return []
        }

        return sections.filter { section in
            // Filter by type
            guard visibleTypes.contains(section.type) else {
                return false
            }

            // Filter by favorites
            if favoritesOnly && !section.favorite {
                return false
            }

            return true
        }
    }

    func loadSections(service: ScheduleService) async {
        state = .loading
        do {
            let sections = try await service.getAllSections()
            allSections = sections
            // Sort by start time
            let sortedSections = sections.sorted(by: { lhs, rhs in
                return lhs.startTime.epochMillis < rhs.startTime.epochMillis
            })
            state = .loaded(sortedSections)

            // Auto-select current day if applicable
            selectCurrentDay(sections: sortedSections)
        } catch {
            state = .error
        }
    }

    func refreshSections(service: ScheduleService) async {
        do {
            _ = try await service.refreshSections()
            // On success, reload the sections from local cache
            await loadSections(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
        }
    }

    func toggleFavorite(section: ScheduleSection, service: ScheduleService) async {
        do {
            try await service.toggleFavorite(sectionId: section.id, favorite: !section.favorite)
            // Reload to reflect changes
            await loadSections(service: service)
        } catch {
            // Handle error silently or show error
        }
    }

    func toggleTypeFilter(_ type: SectionType) {
        if visibleTypes.contains(type) {
            visibleTypes.remove(type)
        } else {
            visibleTypes.insert(type)
        }
    }

    func toggleFavoritesOnly() {
        favoritesOnly.toggle()
    }

    func selectDay(index: Int) {
        selectedDayIndex = index
    }

    private func selectCurrentDay(sections: [ScheduleSection]) {
        let now = Date()
        let currentMillis = Int64(now.timeIntervalSince1970 * 1000)

        // Find first section that is currently happening
        for section in sections {
            if section.startTime.epochMillis <= currentMillis &&
               section.endTime.epochMillis >= currentMillis {
                // Calculate day index from start time
                selectedDayIndex = calculateDayIndex(from: section.startTime.epochMillis)
                return
            }
        }

        // If no current section, find the next upcoming one
        for section in sections {
            if section.startTime.epochMillis > currentMillis {
                selectedDayIndex = calculateDayIndex(from: section.startTime.epochMillis)
                return
            }
        }
    }

    private func calculateDayIndex(from millis: Int64) -> Int {
        // Assuming event starts on a specific date, calculate day index
        // For now, return 0 as default
        // TODO: Implement based on actual event start date from Remote Config
        return 0
    }
}

enum ScheduleState {
    case loading
    case loaded([ScheduleSection])
    case error
}

// MARK: - Section List Item

struct SectionListItem: View {
    let section: ScheduleSection

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(formatTime(section.startTime.epochMillis))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(section.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    let description = section.description
                    if !description.isEmpty {
                        Text(description.prefix(80) + (description.count > 80 ? "..." : ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                if section.favorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }

    private func formatTime(_ millis: Int64) -> String {
        DateFormatter.formatTime(from: millis)
    }
}

// MARK: - Schedule Day Tab

struct ScheduleDayTab: View {
    let selectedDayIndex: Int
    let dayNames: [String]
    let onDaySelected: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(dayNames.enumerated()), id: \.offset) { index, dayName in
                    DayTabItem(
                        dayName: dayName,
                        isSelected: selectedDayIndex == index,
                        isCurrent: isCurrentDay(index: index)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onDaySelected(index)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.background)
    }

    private func isCurrentDay(index: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        // Event starts on Saturday, July 18, 2026
        let components = DateComponents(year: 2026, month: 7, day: 18)
        guard let eventStartDate = calendar.date(from: components) else {
            return false
        }

        let currentDate = calendar.dateComponents([.day], from: eventStartDate, to: now)
        return currentDate.day == index
    }
}

struct DayTabItem: View {
    let dayName: String
    let isSelected: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(dayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.secondary.opacity(0.3) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.secondary : Color.clear,
                            lineWidth: isSelected ? 2 : 0
                        )
                )

            if isSelected {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.xs)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 80)
    }
}

// MARK: - Section Detail View

struct SectionDetailView: View {
    let section: ScheduleSection
    @State private var isFavorite: Bool

    init(section: ScheduleSection) {
        self.section = section
        self._isFavorite = State(initialValue: section.favorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                contentSection
            }
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .secondary)
                }
            }
        }
    }

    private var heroSection: some View {
        ZStack {
            let typeColor = section.type.color
            LinearGradient(
                colors: [typeColor.opacity(0.6), typeColor.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)

            VStack(spacing: Spacing.sm) {
                Image(systemName: section.type.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                Text(section.type.label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Time
            GlassCard {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(Strings.Schedule.Detail.shared.TIME)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Text("\(formatTime(section.startTime.epochMillis)) - \(formatTime(section.endTime.epochMillis))")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, -CornerRadius.large)
            .padding(.horizontal, Spacing.md)

            // Description
            let description = section.description
            if !description.isEmpty {
                GlassCard {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.secondary)
                            Text(Strings.Schedule.Detail.shared.DESCRIPTION)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.md)
    }

    private func formatTime(_ millis: Int64) -> String {
        DateFormatter.formatTime(from: millis)
    }
}

// MARK: - Schedule Filter View

struct ScheduleFilterView: View {
    @Binding var visibleTypes: Set<SectionType>
    @Binding var favoritesOnly: Bool
    @Environment(\.dismiss) private var dismiss

    private let allTypes: [SectionType] = [.main, .internal, .gospel, .food]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, Spacing.md)

                // Filter content
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        // Section type filters
                        ForEach(allTypes, id: \.self) { type in
                            FilterTypeRow(
                                type: type,
                                isVisible: visibleTypes.contains(type),
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        toggleType(type)
                                    }
                                }
                            )
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, Spacing.sm)

                        // Favorites filter
                        FilterToggleRow(
                            title: Strings.Schedule.shared.FAVORITES,
                            icon: "star.fill",
                            color: .yellow,
                            isOn: favoritesOnly,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    favoritesOnly.toggle()
                                }
                            }
                        )

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, Spacing.sm)

                        // Quick actions
                        HStack(spacing: Spacing.md) {
                            Button(action: showAllTypes) {
                                HStack {
                                    Image(systemName: "eye")
                                    Text(Strings.Schedule.shared.SHOW_ALL)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.3))
                                )
                            }

                            Button(action: hideAllTypes) {
                                HStack {
                                    Image(systemName: "eye.slash")
                                    Text(Strings.Schedule.shared.HIDE_ALL)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.3))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .background(Color.background)
            .navigationTitle(Strings.Schedule.shared.FILTER_TITLE)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Strings.Schedule.shared.DONE) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleType(_ type: SectionType) {
        if visibleTypes.contains(type) {
            visibleTypes.remove(type)
        } else {
            visibleTypes.insert(type)
        }
    }

    private func showAllTypes() {
        withAnimation(.easeInOut(duration: 0.3)) {
            visibleTypes = Set(allTypes)
        }
    }

    private func hideAllTypes() {
        withAnimation(.easeInOut(duration: 0.3)) {
            visibleTypes = []
        }
    }
}

struct FilterTypeRow: View {
    let type: SectionType
    let isVisible: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Color indicator
                Circle()
                    .fill(type.color)
                    .frame(width: 16, height: 16)

                Text(type.label)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                if isVisible {
                    Image(systemName: "checkmark")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                GlassCard {
                    EmptyView()
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterToggleRow: View {
    let title: String
    let icon: String
    let color: Color
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)

                Text(title)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                GlassCard {
                    EmptyView()
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Filter View") {
    ScheduleFilterView(
        visibleTypes: .constant(Set([.main, .internal])),
        favoritesOnly: .constant(false)
    )
    .preferredColorScheme(.dark)
}
