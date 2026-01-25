import SwiftUI
import shared
import Kingfisher

struct SpeakerDetailView: View {
    let speaker: Speaker

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                speakerHeroImage
                speakerContent
            }
        }
        .navigationTitle(speaker.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
    }

    private var speakerHeroImage: some View {
        HeroAsyncImageWithFallback(
            url: speaker.imageUrlURL,
            fallbackIconName: "person.fill",
            height: 300
        )
    }

    private var speakerContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = speaker.description_, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding()
                    .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
                    .padding(.top, -CornerRadius.large)
                    .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.xl)
    }
}

// MARK: - Previews

#Preview("Speaker Detail View - With Description") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SpeakerDetailView(speaker: Speaker(
                id: "test1",
                name: "Jan Novák",
                description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu.",
                priority: 1,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.dark)
    } else {
        SpeakerDetailView(speaker: Speaker(
            id: "test1",
            name: "Jan Novák",
            description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu.",
            priority: 1,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.dark)
    }
}

#Preview("Speaker Detail View - Long Biography") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SpeakerDetailView(speaker: Speaker(
                id: "test2",
                name: "Marie Svobodová",
                description: "Známá kazatelka a autorka mnoha knih. Její posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu. Pravidelně přednáší na konferencích a setkáních po celé České republice i v zahraničí. Věnuje se také poradenství pro mladé páry a rodiny. Je vdaná a má tři děti.",
                priority: 2,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.light)
    } else {
        SpeakerDetailView(speaker: Speaker(
            id: "test2",
            name: "Marie Svobodová",
            description: "Známá kazatelka a autorka mnoha knih. Její posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu. Pravidelně přednáší na konferencích a setkáních po celé České republice i v zahraničí. Věnuje se také poradenství pro mladé páry a rodiny. Je vdaná a má tři děti.",
            priority: 2,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.light)
    }
}

#Preview("Speaker Detail View - Without Description") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SpeakerDetailView(speaker: Speaker(
                id: "test3",
                name: "Tomáš Dvořák",
                description: nil,
                priority: 3,
                image: nil,
                imageUrl: nil
            ))
        }
        .preferredColorScheme(.dark)
    } else {
        SpeakerDetailView(speaker: Speaker(
            id: "test3",
            name: "Tomáš Dvořák",
            description: nil,
            priority: 3,
            image: nil,
            imageUrl: nil
        ))
        .preferredColorScheme(.dark)
    }
}
