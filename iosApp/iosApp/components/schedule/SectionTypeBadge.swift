import SwiftUI
import shared

struct SectionTypeBadge: View {
    let type: SectionType

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: type.icon)
                .font(.caption2)
            Text(type.label)
                .font(.caption2)
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(type.color, in: Capsule())
    }
}

#Preview("Section Type Badge") {
    VStack(spacing: 10) {
        SectionTypeBadge(type: .main)
        SectionTypeBadge(type: .gospel)
        SectionTypeBadge(type: .food)
        SectionTypeBadge(type: .internal)
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
