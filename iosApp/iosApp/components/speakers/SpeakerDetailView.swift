import SwiftUI
import shared

struct SpeakerDetailView: View {
    let speakerUid: String
    @Environment(\.speakersService) private var speakersService
    @State private var speaker: Speaker?

    var body: some View {
        Group {
            if let speaker {
                EntityDetailView(entity: speaker, config: .speaker)
            } else {
                ProgressView()
            }
        }
        .task {
            speaker = try? await speakersService.getSpeakerById(uid: speakerUid)
        }
    }
}

// MARK: - Previews

#Preview("Speaker Detail View - With Description") {
    SpeakerDetailView(speakerUid: "test1")
        .environment(\.speakersService, SpeakersService())
        .preferredColorScheme(.dark)
}

#Preview("Speaker Detail View - Long Biography") {
    SpeakerDetailView(speakerUid: "test2")
        .environment(\.speakersService, SpeakersService())
        .preferredColorScheme(.light)
}

#Preview("Speaker Detail View - Without Description") {
    SpeakerDetailView(speakerUid: "test3")
        .environment(\.speakersService, SpeakersService())
        .preferredColorScheme(.dark)
}
