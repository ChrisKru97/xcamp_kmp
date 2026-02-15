import SwiftUI
import shared

struct SpeakersContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = SpeakersViewModel()

    var body: some View {
        EmptyView()
            .switchingContent(viewModel.state) { speakers, _ in
                speakersList(speakers)
            } error: { error in
                ErrorView(error: error) {
                    await viewModel.loadSpeakers()
                }
            }
        .task {
            await viewModel.loadSpeakers()
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    private func speakersList(_ speakers: [Speaker]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(speakers, id: \.uid) { speaker in
                    Button {
                        router.push(speaker.uid, type: .speaker)
                    } label: {
                        SpeakerListItem(speaker: speaker)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshSpeakers()
        }
    }
}

// MARK: - Previews

#Preview("Speakers Content View") {
    SpeakersContentView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
