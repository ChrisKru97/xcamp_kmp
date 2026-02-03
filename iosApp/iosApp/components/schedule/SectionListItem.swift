import SwiftUI
import shared

struct SectionListItem: View, Equatable {
    let section: shared.ExpandedSection

    static func == (lhs: SectionListItem, rhs: SectionListItem) -> Bool {
        lhs.section.uid == rhs.section.uid && lhs.section.favorite == rhs.section.favorite
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(formatTime(section.startTime.epochMillis))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(section.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .contentShape(Rectangle())
        .backport.glassEffect(.regular)
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
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("09:00")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Main Session")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
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
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("14:00")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Workshop: Compose Multiplatform")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
