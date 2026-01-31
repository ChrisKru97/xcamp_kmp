import SwiftUI
import shared

struct SpeakerListItem: View, Equatable {
    let speaker: Speaker

    static func == (lhs: SpeakerListItem, rhs: SpeakerListItem) -> Bool {
        lhs.speaker.uid == rhs.speaker.uid
    }

    var body: some View {
        ImageNameCard(
            name: speaker.name,
            imageUrl: speaker.imageUrlURL,
            fallbackIconName: "person.fill",
            imageShape: .circle
        )
    }
}

// MARK: - Previews

#Preview("Speaker List Item") {
    SpeakerListItem(speaker: Speaker(
        uid: "test1",
        name: "Jan Novák",
        description: nil,
        priority: 1,
        image: nil,
        imageUrl: nil
    ))
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Speaker List Item - Light") {
    SpeakerListItem(speaker: Speaker(
        uid: "test2",
        name: "Marie Svobodová",
        description: nil,
        priority: 2,
        image: nil,
        imageUrl: nil
    ))
    .frame(width: 150)
    .padding()
    .background(Color.background)
    .preferredColorScheme(.light)
}
