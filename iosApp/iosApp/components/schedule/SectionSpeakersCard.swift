import SwiftUI
import shared

struct SectionSpeakersCard: View {
    let speakerUids: [String]

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    @EnvironmentObject var router: AppRouter
    @State private var state: ContentState<[Speaker]> = .loading

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            labelSection

            switchingContent(state, loading: { CardLoadingView() }) { speakers, _ in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(speakers, id: \.uid) { speaker in
                            Button {
                                router.push(speaker.uid, type: .speaker)
                            } label: {
                                speakerChip(speaker)
                            }
                            .glassButton()
                        }
                    }
                    .padding(.horizontal, Spacing.sm)
                }
            } error: { _ in
                CardUnavailableView(message: "Speakers Not Available")
            }
        }.padding(Spacing.md)
        .card()
        .task {
            await loadSpeakers()
        }
    }

    private func loadSpeakers() async {
        var loaded: [Speaker] = []
        for uid in speakerUids {
            guard !Task.isCancelled else { return }
            if let speaker = try? await speakersService.getSpeakerById(uid: uid) {
                loaded.append(speaker)
            }
        }
        guard !Task.isCancelled else { return }
        state = .loaded(loaded)
    }

    private func speakerChip(_ speaker: Speaker) -> some View {
        HStack(spacing: Spacing.xs) {
            AsyncImage(url: speaker.imageUrlURL) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            Text(speaker.name)
                .font(.subheadline)
                .foregroundColor(.primary)

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.secondary.opacity(0.1), in: Capsule())
    }

    private var labelSection: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "person.2.fill")
                .foregroundColor(.secondary)
            Text(Strings.ScheduleDetail.shared.DETAIL_SPEAKERS)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SectionSpeakersCard(speakerUids: ["test-speaker-1", "test-speaker-2"])
        .environmentObject(AppRouter())
}
