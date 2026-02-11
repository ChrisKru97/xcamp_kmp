import SwiftUI
import shared

struct SectionLeaderCard: View {
    let leaderUid: String

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    @EnvironmentObject var router: AppRouter
    @State private var leader: Speaker?

    var body: some View {
        Group {
            if let leader = leader {
                Button {
                    router.push(leader.uid, type: .speaker)
                } label: {
                    cardContent(leader.name)
                }
                .glassButton()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .task {
            let result = try? await speakersService.getSpeakerById(uid: leaderUid)
            guard !Task.isCancelled else { return }
            leader = result
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

#Preview {
    SectionLeaderCard(leaderUid: "test-leader-id")
        .environmentObject(AppRouter())
}
