import SwiftUI
import shared

struct SpeakerDetailView: View {
    let speakerUid: String
    @State private var state: ContentState<Speaker> = .loading

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    var body: some View {
        EmptyView()
            .switchingContent(state) { speaker, _ in
                EntityDetailView(entity: speaker, config: .speaker)
            } error: { error in
                ErrorView(error: error) {
                    await loadSpeaker()
                }
            }
            .task {
                await loadSpeaker()
            }
            .onAppear {
                Analytics.shared.logScreenView(screenName: "speaker_detail")
                if case .loaded(let speaker, _) = state {
                    Analytics.shared.logEvent(
                        name: AnalyticsEvents.shared.CONTENT_VIEW,
                        parameters: [
                            AnalyticsEvents.shared.PARAM_CONTENT_TYPE: "speaker",
                            AnalyticsEvents.shared.PARAM_CONTENT_ID: speaker.uid,
                            AnalyticsEvents.shared.PARAM_ENTITY_NAME: speaker.name
                        ]
                    )
                }
            }
    }

    private func loadSpeaker() async {
        do {
            let result = try await speakersService.getSpeakerById(uid: speakerUid)
            guard !Task.isCancelled else { return }
            if let speaker = result as? Speaker {
                state = .loaded(speaker)
            } else {
                state = .error(AppError.notFound)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
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
