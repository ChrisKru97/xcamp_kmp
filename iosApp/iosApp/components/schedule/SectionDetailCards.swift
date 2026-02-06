import SwiftUI
import shared

struct SectionTimeCard: View {
    let startTimeString: String
    let endTimeString: String

    init(startTimeString: String, endTimeString: String) {
        self.startTimeString = startTimeString
        self.endTimeString = endTimeString
    }

    var body: some View {
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
                Text("\(startTimeString) - \(endTimeString)")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct SectionDescriptionCard: View {
    let description: String

    var body: some View {
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
    }
}

#Preview("Section Time Card") {
    VStack(spacing: 20) {
        SectionTimeCard(startTimeString: "09:00", endTimeString: "10:30")
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
