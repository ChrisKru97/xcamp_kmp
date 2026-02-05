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
        MeshGradient(
            width: 2,
            height: 2,
            points: [
                .zero,
                [1, 0],
                [0, 1],
                [1, 1]
            ],
            colors: colors
        )
        .ignoresSafeArea()
    }

    private var colors: [Color] {
        colorScheme == .dark ? darkColors : lightColors
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
            Color(red: 0.51, green: 0.85, blue: 0.98),
            Color(red: 0.37, green: 0.60, blue: 0.85),
            Color(red: 0.05, green: 0.38, blue: 0.68)
        ]
    }

    private var darkColors: [Color] {
        [
            Color(red: 0.05, green: 0.38, blue: 0.68),
            Color(red: 0.07, green: 0.27, blue: 0.48),
            Color(red: 0.05, green: 0.25, blue: 0.45)
        ]
    }
}
