import SwiftUI
import shared

struct SectionDetailView: View {
    let section: shared.Section
    let service: ScheduleService
    let onFavoriteToggled: () -> Void

    @State private var isFavorite: Bool

    init(section: shared.Section, service: ScheduleService, onFavoriteToggled: @escaping () -> Void) {
        self.section = section
        self.service = service
        self.onFavoriteToggled = onFavoriteToggled
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
                Button(action: {
                    Task {
                        isFavorite.toggle()
                        try? await service.toggleFavorite(sectionId: section.id, favorite: isFavorite)
                        onFavoriteToggled()
                    }
                }) {
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
                        Text(Strings.ScheduleDetail.shared.DETAIL_TIME)
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
                            Text(Strings.ScheduleDetail.shared.DETAIL_DESCRIPTION)
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

// MARK: - Previews

#Preview("Section Detail View - Main") {
    NavigationView {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section simulation
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)

                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("Hlavní")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                // Content section simulation
                VStack(alignment: .leading, spacing: Spacing.lg) {
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
                            Text("09:00 - 10:30")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, -CornerRadius.large)
                    .padding(.horizontal, Spacing.md)

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
                            Text("Ranní chvály a hlavní téma dne. Přijďte si užít worship společně s celým táborem.")
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(.top, Spacing.md)
            }
        }
        .navigationTitle("Ranní chvály")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Section Detail View - Gospel") {
    NavigationView {
        ScrollView {
            VStack(spacing: 0) {
                // Hero section simulation
                ZStack {
                    LinearGradient(
                        colors: [Color.purple.opacity(0.6), Color.purple.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)

                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("Evangelium")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                // Content section simulation
                VStack(alignment: .leading, spacing: Spacing.lg) {
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
                            Text("19:00 - 20:30")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, -CornerRadius.large)
                    .padding(.horizontal, Spacing.md)

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
                            Text("Večerní evangelizace a závěrečné modlitby.")
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(.top, Spacing.md)
            }
        }
        .navigationTitle("Večerní evangelium")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "star")
                    .foregroundColor(.secondary)
            }
        }
    }
    .preferredColorScheme(.light)
}
