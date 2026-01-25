import SwiftUI
import shared

struct SectionTimeCard: View {
    let startTime: Int64
    let endTime: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(Strings.ScheduleDetail.shared.DETAIL_TIME)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Text("\(DateFormatter.formatTime(from: startTime)) - \(DateFormatter.formatTime(from: endTime))")
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Strings.ScheduleDetail.shared.DETAIL_TIME): \(DateFormatter.formatTime(from: startTime)) - \(DateFormatter.formatTime(from: endTime))")
    }
}

struct SectionDescriptionCard: View {
    let description: String

    var body: some View {
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
        .padding()
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(Strings.ScheduleDetail.shared.DETAIL_DESCRIPTION): \(description)")
    }
}

#Preview("Section Time Card") {
    VStack(spacing: 20) {
        SectionTimeCard(startTime: 1701234567000, endTime: 1701238167000)
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Section Description Card") {
    VStack(spacing: 20) {
        SectionDescriptionCard(description: "Ranní chvály a hlavní téma dne. Přijďte si užít worship společně s celým táborem.")
        SectionDescriptionCard(description: "Večerní evangelizace a závěrečné modlitby.")
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}
