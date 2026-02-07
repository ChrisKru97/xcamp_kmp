import SwiftUI
import shared

struct SectionLeaderCard: View {
    let leaderUid: String
    let speakersService: SpeakersService

    @EnvironmentObject var router: AppRouter
    @State private var leader: Speaker?

    var body: some View {
        Group {
            if let leader = leader {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    router.push(leader.uid, type: .speaker)
                } label: {
                    cardContent(leader.name)
                }
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
            HStack {
                labelSection
                Spacer()
                Text(leaderName)
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.padding(Spacing.md)
            .card()
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
