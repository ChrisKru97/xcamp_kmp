import SwiftUI
import shared

struct ScheduleFilterFab: View {
    @Environment(\.scheduleFilter) var scheduleFilter
    var action: () -> Void = {}

    var body: some View { // TODO reuse the correct background color and make it circular
        Button(action: action) {
            buttonIcon
                .font(.title2)
                .foregroundColor(buttonForegroundColor)
        }
        .backport.glassButtonStyle(fallbackStyle: .bordered)
        .backport.glassProminentButtonStyle()
    }

    @ViewBuilder
    private var buttonIcon: some View {
        Image(systemName: iconName)
    }

    private var iconName: String {
        if filterState == .inactive {
            return "line.3.horizontal.decrease.circle"
        }
        return "line.3.horizontal.decrease.circle.fill"
    }

    private var buttonForegroundColor: Color {
        switch filterState {
        case .inactive:
            return .primary
        case .active, .favorites:
            return .white
        }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch filterState {
        case .inactive:
            EmptyView()
        case .active:
            Gradient.accent
        case .favorites:
            Gradient.favorites
        }
    }

    private enum FilterState {
        case inactive
        case active
        case favorites
    }

    private var filterState: FilterState {
        if scheduleFilter.favoritesOnly.wrappedValue {
            return .favorites
        }
        if scheduleFilter.visibleTypes.wrappedValue.count != SectionType.entries.count {
            return .active
        }
        return .inactive
    }
}

// MARK: - Previews

#Preview("Filter FAB - Inactive") {
    ScheduleFilterFab()
        .environment(
            \.scheduleFilter,
            (visibleTypes: .constant(Set([.main, .internal, .gospel, .food])), favoritesOnly: .constant(false))
        )
        .padding()
        .background(Color.background)
        .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Active") {
    ScheduleFilterFab()
        .environment(
            \.scheduleFilter,
            (visibleTypes: .constant(Set([.main, .internal])), favoritesOnly: .constant(false))
        )
        .padding()
        .background(Color.background)
        .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Favorites") {
    ScheduleFilterFab()
        .environment(
            \.scheduleFilter,
            (visibleTypes: .constant(Set([.main, .internal, .gospel, .food])), favoritesOnly: .constant(true))
        )
        .padding()
        .background(Color.background)
        .preferredColorScheme(.dark)
}
