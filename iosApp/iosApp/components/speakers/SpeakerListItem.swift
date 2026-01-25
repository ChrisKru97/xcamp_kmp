import SwiftUI
import shared
import Kingfisher

struct SpeakerListItem: View, Equatable {
    let speaker: Speaker

    static func == (lhs: SpeakerListItem, rhs: SpeakerListItem) -> Bool {
        lhs.speaker.id == rhs.speaker.id
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            speakerImage
            speakerInfo
            Spacer(minLength: Spacing.xs)
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
    }

    private var speakerImage: some View {
        AsyncImageWithFallback(
            url: speaker.imageUrlURL,
            fallbackIconName: "person.fill",
            size: CGSize(width: 60, height: 60)
        )
        .clipShape(Circle())
    }

    private var speakerInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(speaker.name)
                .font(.headline)
                .foregroundColor(.primary)
            // Use description_ to avoid conflict with Swift's built-in .description
            let speakerDescription = speaker.description_ ?? ""
            if !speakerDescription.isEmpty {
                Text(speakerDescription.prefix(120) + (speakerDescription.count > 120 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)  // Increased from 2
            }
        }
    }
}

// MARK: - Previews

#Preview("Speaker List Item - With Description") {
    SpeakerListItem(speaker: Speaker(
        id: "test1",
        name: "Jan Novák",
        description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let.",
        priority: 1,
        image: nil,
        imageUrl: nil
    ))
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Speaker List Item - Without Description") {
    SpeakerListItem(speaker: Speaker(
        id: "test2",
        name: "Marie Svobodová",
        description: nil,
        priority: 2,
        image: nil,
        imageUrl: nil
    ))
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}

#Preview("Speaker List Item - Long Description") {
    SpeakerListItem(speaker: Speaker(
        id: "test3",
        name: "Tomáš Dvořák",
        description: "Známý kazatel a autor mnoha knih. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu. Pravidelně přednáší na konferencích a setkáních po celé České republice i v zahraničí. Je ženatý a má tři děti.",
        priority: 3,
        image: nil,
        imageUrl: nil
    ))
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}
