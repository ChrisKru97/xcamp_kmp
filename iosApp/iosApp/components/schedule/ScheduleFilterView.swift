import SwiftUI
import shared

struct ScheduleFilterView: View {
    @Binding var visibleTypes: Set<SectionType>
    @Binding var favoritesOnly: Bool
    @Environment(\.dismiss) private var dismiss

    private let allTypes: [SectionType] = [.main, .internal, .gospel, .food]

    var body: some View {
        contentView
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Spacing.md) {
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
                Circle()
                    .fill(type.color)
                    .frame(width: 16, height: 16)

                Text(type.label)
                    .font(.body)
                    .foregroundColor(.secondary)

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
                EmptyView()
                    .padding()
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
                    .foregroundColor(.secondary)

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
                EmptyView()
                    .padding()
            )
        }
        .buttonStyle(PlainButtonStyle())
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

#Preview("Filter Type Row") {
    VStack(spacing: Spacing.sm) {
        FilterTypeRow(
            type: .main,
            isVisible: true,
            onTap: {}
        )
        FilterTypeRow(
            type: .internal,
            isVisible: false,
            onTap: {}
        )
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Filter Toggle Row") {
    VStack(spacing: Spacing.sm) {
        FilterToggleRow(
            title: "Oblíbené",
            icon: "star.fill",
            color: .yellow,
            isOn: true,
            onTap: {}
        )
        FilterToggleRow(
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
