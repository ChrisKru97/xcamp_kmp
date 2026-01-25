import SwiftUI
import shared

struct SectionDetailHero: View {
    let type: SectionType

    var body: some View {
        ZStack {
            let typeColor = type.color
            LinearGradient(
                colors: [typeColor.opacity(0.6), typeColor.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)

            VStack(spacing: Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                Text(type.label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Section Detail Hero - Main") {
    SectionDetailHero(type: .main)
        .preferredColorScheme(.dark)
}

#Preview("Section Detail Hero - Gospel") {
    SectionDetailHero(type: .gospel)
        .preferredColorScheme(.light)
}

#Preview("Section Detail Hero - Food") {
    SectionDetailHero(type: .food)
        .preferredColorScheme(.dark)
}

#Preview("Section Detail Hero - Internal") {
    SectionDetailHero(type: .internal)
        .preferredColorScheme(.light)
}
