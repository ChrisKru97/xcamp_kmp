import SwiftUI
import shared

struct SectionLeaderCard: View {
    let leaderUid: String
    let speakersService: SpeakersService

    @State private var leader: Speaker?

    var body: some View {
        Group {
            if let leader = leader {
                NavigationLink(destination: SpeakerDetailView(speaker: leader)) {
                    cardContent(leader.name)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .task {
            leader = try? await speakersService.getSpeakerById(uid: leaderUid)
        }
    }

    private func cardContent(_ leaderName: String) -> some View {
        GlassCard {
            HStack {
                labelSection
                Spacer()
                Text(leaderName)
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var labelSection: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "person.circle")
                .foregroundColor(.secondary)
            Text(Strings.ScheduleDetail.shared.DETAIL_LEADER)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
