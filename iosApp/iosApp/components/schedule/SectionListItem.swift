import SwiftUI
import shared

struct SectionListItem: View {
    let section: shared.Section

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

// MARK: - Previews

#Preview("Section List Item") {
    // Note: Preview data requires valid Section construction
    // For now, showing placeholder preview structure
    Text("Section List Item Preview")
        .foregroundColor(.white)
}
