import SwiftUI
import shared

// Typealias to avoid ambiguity with SwiftUI.Section
typealias ScheduleSection = shared.Section

struct ScheduleView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = ScheduleViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()

                switch viewModel.state {
                case .loading:
                    loadingView
                case .loaded(let sections):
                    if sections.isEmpty {
                        emptyView
                    } else {
                        scheduleContent(sections)
                    }
                case .error:
                    errorView
                }
            }
            .navigationTitle(Strings.Tabs.shared.SCHEDULE)
            .task {
                await viewModel.loadSections(service: appViewModel.getScheduleService())
            }
        }
    }

    private func scheduleContent(_ sections: [ScheduleSection]) -> some View {
        VStack(spacing: 0) {
            // Day tabs will be added in next task
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
    @Published private(set) var visibleTypes: Set<SectionType> = Set([
        .main, .internal, .gospel, .food
    ])
    @Published private(set) var favoritesOnly: Bool = false

    private var allSections: [ScheduleSection] = []

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
        let date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: date)
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
            let typeColor = colorForSectionType(section.type)
            LinearGradient(
                colors: [typeColor.opacity(0.6), typeColor.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)

            VStack(spacing: Spacing.sm) {
                Image(systemName: iconForSectionType(section.type))
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                Text(typeLabelForSectionType(section.type))
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
                        Text("Čas")
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
                            Text("Popis")
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
        let date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter.string(from: date)
    }

    private func colorForSectionType(_ type: SectionType) -> Color {
        switch type {
        case .main:
            return .purple
        case .internal:
            return .green
        case .gospel:
            return .pink
        case .food:
            return .yellow
        case .basic:
            return .purple
        default:
            return .gray
        }
    }

    private func iconForSectionType(_ type: SectionType) -> String {
        switch type {
        case .main:
            return "star.fill"
        case .internal:
            return "person.3.fill"
        case .gospel:
            return "heart.fill"
        case .food:
            return "fork.knife"
        case .basic:
            return "star.fill"
        default:
            return "calendar"
        }
    }

    private func typeLabelForSectionType(_ type: SectionType) -> String {
        switch type {
        case .main:
            return "Hlavní"
        case .internal:
            return "Interní"
        case .gospel:
            return "Gospel"
        case .food:
            return "Jídlo"
        case .basic:
            return "Hlavní"
        default:
            return "Ostatní"
        }
    }
}

// MARK: - Previews

#Preview("Schedule View") {
    ScheduleView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
