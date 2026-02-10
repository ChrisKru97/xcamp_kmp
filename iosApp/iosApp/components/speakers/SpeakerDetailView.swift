import SwiftUI
import shared

struct SpeakerDetailView: View {
    let speakerUid: String
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
            speaker = try? await ServiceFactory.shared.getSpeakersService().getSpeakerById(uid: speakerUid)
        }
    }
}

// MARK: - Previews

#Preview("Speaker Detail View - With Description") {
    SpeakerDetailView(speakerUid: "test1")
        .preferredColorScheme(.dark)
}

#Preview("Speaker Detail View - Long Biography") {
    SpeakerDetailView(speakerUid: "test2")
        .preferredColorScheme(.light)
}

#Preview("Speaker Detail View - Without Description") {
    SpeakerDetailView(speakerUid: "test3")
        .preferredColorScheme(.dark)
}
