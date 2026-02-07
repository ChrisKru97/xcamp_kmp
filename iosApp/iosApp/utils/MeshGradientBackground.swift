import SwiftUI

struct MeshGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradientView()
        } else {
            FallbackGradientView()
        }
    }
}

@available(iOS 18.0, *)
private struct MeshGradientView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSince1970

            MeshGradient(
                width: 2,
                height: 2,
                points: [
                    .zero,
                    [1, 0],
                    [0, 1],
                    [1, 1]
                ],
                colors: animatingColors(phase: phase),
                smoothsColors: true
            )
            .ignoresSafeArea()
        }
    }

    private func animatingColors(phase: TimeInterval) -> [Color] {
        let baseColors = colorScheme == .dark ? darkColors : lightColors

        return baseColors.enumerated().map { index, color in
            let phaseOffset = phase * .pi * 2 / 5
            let indexOffset = Double(index) * .pi / 2
            let sineValue = sin(indexOffset + phaseOffset)
            let shift = sineValue * 0.2
            let rawOpacity = 0.7 + shift
            let clampedOpacity = max(0.5, min(1.0, rawOpacity))
            return color.opacity(clampedOpacity)
        }
    }

    private var lightColors: [Color] {
        [
            Color(red: 0.37, green: 0.60, blue: 0.85),
            Color(red: 0.51, green: 0.85, blue: 0.98),
            Color(red: 0.59, green: 0.83, blue: 0.92),
            Color(red: 0.73, green: 0.89, blue: 0.91)
        ]
    }

    private var darkColors: [Color] {
        [
            Color(red: 0.05, green: 0.25, blue: 0.45),
            Color(red: 0.05, green: 0.38, blue: 0.68),
            Color(red: 0.33, green: 0.60, blue: 0.88),
            Color(red: 0.07, green: 0.27, blue: 0.48)
        ]
    }
}

private struct FallbackGradientView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var colors: [Color] {
        colorScheme == .dark ? darkColors : lightColors
    }

    private var lightColors: [Color] {
        [
            Color(red: 0.73, green: 0.89, blue: 0.91),
            Color(red: 0.59, green: 0.83, blue: 0.92),
            Color(red: 0.51, green: 0.85, blue: 0.98)
        ]
    }

    private var darkColors: [Color] {
        [
            Color(red: 0.33, green: 0.60, blue: 0.88),
            Color(red: 0.05, green: 0.38, blue: 0.68),
            Color(red: 0.07, green: 0.27, blue: 0.48)
        ]
    }
}
