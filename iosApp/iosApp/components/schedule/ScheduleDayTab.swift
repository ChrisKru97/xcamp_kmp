import SwiftUI

struct ScheduleDayTab: View {
    let selectedDayIndex: Int
    let dayNames: [String]
    let onDaySelected: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(dayNames.enumerated()), id: \.offset) { index, dayName in
                    DayTabItem(
                        dayName: dayName,
                        isSelected: selectedDayIndex == index,
                        isCurrent: isCurrentDay(index: index)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onDaySelected(index)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Spacing.sm)
        .background(Color.background)
    }

    private func isCurrentDay(index: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        // Event starts on Saturday, July 18, 2026
        let components = DateComponents(year: 2026, month: 7, day: 18)
        guard let eventStartDate = calendar.date(from: components) else {
            return false
        }

        let currentDate = calendar.dateComponents([.day], from: eventStartDate, to: now)
        return currentDate.day == index
    }
}

struct DayTabItem: View {
    let dayName: String
    let isSelected: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(dayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.secondary.opacity(0.3) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.secondary : Color.clear,
                            lineWidth: isSelected ? 2 : 0
                        )
                )

            if isSelected {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.xs)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 80)
    }
}

// MARK: - Previews

#Preview("Day Tab") {
    VStack(spacing: Spacing.lg) {
        ScheduleDayTab(
            selectedDayIndex: 0,
            dayNames: ["Sobota", "Neděle", "Pondělí", "Úterý"],
            onDaySelected: { _ in }
        )
        ScheduleDayTab(
            selectedDayIndex: 2,
            dayNames: ["Sobota", "Neděle", "Pondělí", "Úterý"],
            onDaySelected: { _ in }
        )
    }
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Day Tab Item") {
    HStack(spacing: Spacing.md) {
        DayTabItem(dayName: "Sobota", isSelected: false, isCurrent: false)
        DayTabItem(dayName: "Neděle", isSelected: true, isCurrent: true)
        DayTabItem(dayName: "Pondělí", isSelected: false, isCurrent: false)
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
