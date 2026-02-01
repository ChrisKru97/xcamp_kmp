import SwiftUI
import shared

struct SpeakerDetailView: View {
    let speaker: Speaker

    var body: some View {
        EntityDetailView(
            entity: speaker,
            config: .speaker
        )
    }
}

// MARK: - Previews

#Preview("Speaker Detail View - With Description") {
    SpeakerDetailView(speaker: Speaker(
                uid: "test1",
                name: "Jan Novák",
                description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu.",
                priority: 1,
                image: nil,
                imageUrl: nil
            ))
        .preferredColorScheme(.dark)
}

#Preview("Speaker Detail View - Long Biography") {
    SpeakerDetailView(speaker: Speaker(
        uid: "test2",
        name: "Marie Svobodová",
        description: "Známá kazatelka a autorka mnoha knih. Její posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu. Pravidelně přednáší na konferencích a setkáních po celé České republice i v zahraničí. Věnuje se také poradenství pro mladé páry a rodiny. Je vdaná a má tři děti.",
        priority: 2,
        image: nil,
        imageUrl: nil
    ))
    .preferredColorScheme(.light)
}

#Preview("Speaker Detail View - Without Description") {
    SpeakerDetailView(speaker: Speaker(
        uid: "test3",
        name: "Tomáš Dvořák",
        description: nil,
        priority: 3,
        image: nil,
        imageUrl: nil
    ))
    .preferredColorScheme(.dark)
}
