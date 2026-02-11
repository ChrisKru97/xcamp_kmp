import SwiftUI
import shared

struct ScheduleFilterFab: View {
    let filterState: ScheduleFilterState
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            buttonIcon
                .font(.system(size: 18))
                .foregroundColor(buttonForegroundColor)
        }
        .scaleButton(scale: 0.90)
        .circularFab(
            glassEffect: glassEffectForState,
            fallbackBackground: fallbackBackgroundForState
        )
    }

    @ViewBuilder
    private var buttonIcon: some View {
        Image(systemName: iconName)
    }

    private var iconName: String {
        if fabState == .inactive {
            return "line.3.horizontal.decrease.circle"
        }
        return "line.3.horizontal.decrease.circle.fill"
    }

    private var buttonForegroundColor: Color {
        switch fabState {
        case .inactive:
            return .primary
        case .active, .favorites:
            return .white
        }
    }

    private enum FabState {
        case inactive
        case active
        case favorites
    }

    private var fabState: FabState {
        if filterState.favoritesOnly {
            return .favorites
        }
        if filterState.visibleTypes.count != SectionType.entries.count {
            return .active
        }
        return .inactive
    }

    private var glassEffectForState: BackportGlass {
        switch fabState {
        case .inactive:
            return .regular
        case .active:
            return .tinted(Color.accent)
        case .favorites:
            return .tinted(Color.orange)
        }
    }

    private var fallbackBackgroundForState: AnyShapeStyle {
        switch fabState {
        case .inactive:
            return AnyShapeStyle(.thinMaterial)
        case .active:
            return AnyShapeStyle(Gradient.accent)
        case .favorites:
            return AnyShapeStyle(Gradient.favorites)
        }
    }
}

// MARK: - Previews

#Preview("Filter FAB - Inactive") {
    ScheduleFilterFab(
        filterState: ScheduleFilterState(
            visibleTypes: Set([.main, .internal, .gospel, .food]),
            favoritesOnly: false
        )
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Active") {
    ScheduleFilterFab(
        filterState: ScheduleFilterState(
            visibleTypes: Set([.main, .internal]),
            favoritesOnly: false
        )
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Favorites") {
    ScheduleFilterFab(
        filterState: ScheduleFilterState(
            visibleTypes: Set([.main, .internal, .gospel, .food]),
            favoritesOnly: true
        )
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
