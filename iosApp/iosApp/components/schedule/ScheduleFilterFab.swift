import SwiftUI
import shared

struct ScheduleFilterFab: View {
    let visibleTypes: Set<SectionType>
    let favoritesOnly: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            buttonIcon
                .font(.system(size: 18))
                .foregroundColor(buttonForegroundColor)
        }
        .buttonStyle(.plain)
        .frame(width: 48, height: 48)
        .contentShape(Circle())
        .backport.glassEffect(
            glassEffectForState,
            in: Circle(),
            fallbackBackground: fallbackBackgroundForState
        )
        .fabShadow()
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

    private enum FilterState {
        case inactive
        case active
        case favorites
    }

    private var filterState: FilterState {
        if favoritesOnly {
            return .favorites
        }
        if visibleTypes.count != SectionType.entries.count {
            return .active
        }
        return .inactive
    }

    private var glassEffectForState: BackportGlass {
        switch filterState {
        case .inactive:
            return .regular
        case .active:
            return .tinted(Color.accent)
        case .favorites:
            return .tinted(Color.orange)
        }
    }

    private var fallbackBackgroundForState: AnyShapeStyle {
        switch filterState {
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
        visibleTypes: Set([.main, .internal, .gospel, .food]),
        favoritesOnly: false
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Active") {
    ScheduleFilterFab(
        visibleTypes: Set([.main, .internal]),
        favoritesOnly: false
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter FAB - Favorites") {
    ScheduleFilterFab(
        visibleTypes: Set([.main, .internal, .gospel, .food]),
        favoritesOnly: true
    )
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
