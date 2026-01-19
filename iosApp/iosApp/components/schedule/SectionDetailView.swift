import SwiftUI
import shared

struct SectionDetailView: View {
    let section: shared.Section
    @State private var isFavorite: Bool

    init(section: shared.Section) {
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
        DateFormatter.formatTime(from: millis)
    }
}

// MARK: - Previews

#Preview("Section Detail View") {
    // Note: Preview data requires valid Section construction
    // For now, showing placeholder preview structure
    Text("Section Detail Preview")
        .foregroundColor(.white)
}
