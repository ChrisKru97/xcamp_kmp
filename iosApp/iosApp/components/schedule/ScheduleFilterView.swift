import SwiftUI
import shared

struct ScheduleFilterView: View {
    @Binding var visibleTypes: Set<SectionType>
    @Binding var favoritesOnly: Bool

    private let allTypes: [SectionType] = SectionType.entries

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                ForEach(Array(allTypes.enumerated()), id: \.element) { index, type in
                    FilterTypeCard(
                        type: type,
                        isVisible: visibleTypes.contains(type),
                        onTap: {
                            HapticManager.shared.selectionChanged()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                toggleType(type)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .opacity
                    ))
                }

                FilterToggleCard(
                    title: Strings.Schedule.shared.FAVORITES,
                    icon: "star.fill",
                    color: .yellow,
                    isOn: favoritesOnly,
                    onTap: {
                        HapticManager.shared.selectionChanged()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            favoritesOnly.toggle()
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            .padding(Spacing.md)
        }
    }

    private func toggleType(_ type: SectionType) {
        var newTypes = visibleTypes
        if newTypes.contains(type) {
            newTypes.remove(type)
        } else {
            newTypes.insert(type)
        }
        visibleTypes = newTypes
    }
}

struct FilterTypeCard: View {
    let type: SectionType
    let isVisible: Bool
    let onTap: () -> Void

    var body: some View {
        FilterCard(
            title: type.label,
            isActive: isVisible,
            color: type.color,
            onTap: onTap
        ) {
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.2))
                    .frame(width: 32, height: 32)

                Circle()
                    .fill(type.color)
                    .frame(width: isVisible ? 24 : 12, height: isVisible ? 24 : 12)
            }
        }
    }
}

struct FilterToggleCard: View {
    let title: String
    let icon: String
    let color: Color
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        FilterCard(
            title: title,
            isActive: isOn,
            color: color,
            onTap: onTap
        ) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)
                    .opacity(isOn ? 1.0 : 0.5)
            }
        }
    }
}

struct FilterCard<LeadingContent: View>: View {
    let title: String
    let isActive: Bool
    let color: Color
    let onTap: () -> Void
    let leadingContent: LeadingContent

    init(
        title: String,
        isActive: Bool,
        color: Color,
        onTap: @escaping () -> Void,
        @ViewBuilder leadingContent: () -> LeadingContent
    ) {
        self.title = title
        self.isActive = isActive
        self.color = color
        self.onTap = onTap
        self.leadingContent = leadingContent()
    }

    var body: some View {
            Button(action: onTap) {
                HStack(spacing: Spacing.md) {
                    leadingContent
                    Text(title)
                        .font(.body)
                        .foregroundColor(isActive ? .secondary : Color.black.opacity(0.3))
                    Spacer()
                    if isActive {
                        checkmark
                    }
                }
            }.backport.glassButtonStyle(fallbackStyle: .bordered)
    }

    private var checkmark: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(color)
            .font(.title3)
            .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Previews

#Preview("Filter View") {
    ScheduleFilterView(
        visibleTypes: .constant(Set([.main, .internal])),
        favoritesOnly: .constant(false)
    )
    .preferredColorScheme(.dark)
}

#Preview("Filter View - All Selected") {
    ScheduleFilterView(
        visibleTypes: .constant(Set([.main, .internal, .gospel, .food])),
        favoritesOnly: .constant(false)
    )
    .preferredColorScheme(.dark)
}

#Preview("Filter View - With Favorites") {
    ScheduleFilterView(
        visibleTypes: .constant(Set([.main])),
        favoritesOnly: .constant(true)
    )
    .preferredColorScheme(.dark)
}

#Preview("Filter Type Card") {
    VStack(spacing: Spacing.md) {
        FilterTypeCard(
            type: .main,
            isVisible: true,
            onTap: {}
        )
        FilterTypeCard(
            type: .internal,
            isVisible: false,
            onTap: {}
        )
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter Toggle Card") {
    VStack(spacing: Spacing.md) {
        FilterToggleCard(
            title: "Oblíbené",
            icon: "star.fill",
            color: .yellow,
            isOn: true,
            onTap: {}
        )
        FilterToggleCard(
            title: "Oblíbené",
            icon: "star.fill",
            color: .yellow,
            isOn: false,
            onTap: {}
        )
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
