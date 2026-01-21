import SwiftUI
import shared

struct SectionListItem: View, Equatable {
    let section: shared.Section

    static func == (lhs: SectionListItem, rhs: SectionListItem) -> Bool {
        lhs.section.id == rhs.section.id && lhs.section.favorite == rhs.section.favorite
    }

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
                        .fixedSize(horizontal: false, vertical: true)
                    let description = section.description
                    if !description.isEmpty {
                        Text(description.prefix(80) + (description.count > 80 ? "..." : ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: Spacing.xs)
                if section.favorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .fillMaxWidthLeading()
        }
        .fillMaxWidthLeading()
    }

    private func formatTime(_ millis: Int64) -> String {
        DateFormatter.formatTime(from: millis)
    }
}

// MARK: - Previews

#Preview("Section List Item - Light") {
    VStack(spacing: Spacing.md) {
        Text("SectionListItem Preview")
            .font(.caption)
            .foregroundColor(.secondary)
        Text("Note: Requires running app with actual Schedule data")
            .font(.caption2)
            .foregroundColor(.secondary)
        GlassCard {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("09:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Main Session")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Opening worship and welcome message...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}

#Preview("Section List Item - Dark") {
    VStack(spacing: Spacing.md) {
        Text("SectionListItem Preview (Dark)")
            .font(.caption)
            .foregroundColor(.secondary)
        GlassCard {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("14:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Workshop: Compose Multiplatform")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Learn Kotlin multiplatform UI development...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
