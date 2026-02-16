import SwiftUI
import shared

struct SectionLeaderCard: View {
    let leaderUid: String

    var speakersService: SpeakersService { ServiceFactory.shared.getSpeakersService() }

    @EnvironmentObject var router: AppRouter
    @State private var state: ContentState<Speaker> = .loading

    var body: some View {
        bodyContent
            .task {
                await loadLeader()
            }
    }

    @ViewBuilder
    private var bodyContent: some View {
        switchingContent(state, loading: { CardLoadingView() }) { leader, _ in
            Button {
                router.push(leader.uid, type: .speaker)
            } label: {
                cardContent(leader.name)
            }
            .glassButton()
        } error: { _ in
            CardUnavailableView(message: "Leader Not Available")
        }
    }

    private func loadLeader() async {
        do {
            let result = try await speakersService.getSpeakerById(uid: leaderUid)
            guard !Task.isCancelled else { return }
            if let leader = result {
                state = .loaded(leader)
            } else {
                state = .error(AppError.notFound)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(AppError.notFound)
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
