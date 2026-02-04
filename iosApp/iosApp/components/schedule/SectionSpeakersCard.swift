import SwiftUI
import shared

struct SectionSpeakersCard: View {
    let speakerUids: [String]
    let speakersService: SpeakersService

    @EnvironmentObject var router: AppRouter
    @State private var speakers: [Speaker] = []

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                labelSection

                if speakers.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(speakers, id: \.uid) { speaker in
                                Button {
                                    router.push(speaker.uid)
                                } label: {
                                    speakerChip(speaker)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.sm)
                    }
                }
            }
        }
        .task {
            await loadSpeakers()
        }
    }

    private func loadSpeakers() async {
        var loaded: [Speaker] = []
        for uid in speakerUids {
            if let speaker = try? await speakersService.getSpeakerById(uid: uid) {
                loaded.append(speaker)
            }
        }
        speakers = loaded
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
