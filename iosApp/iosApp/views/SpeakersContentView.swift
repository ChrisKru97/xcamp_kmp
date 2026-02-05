import SwiftUI
import shared

struct SpeakersContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = SpeakersViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded(let speakers):
                if speakers.isEmpty {
                    emptyView
                } else {
                    speakersList(speakers)
                }
            case .error:
                errorView
            }
        }
        .task {
            await viewModel.loadSpeakers(service: appViewModel.speakersService)
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
                            .equatable()
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshSpeakers(service: appViewModel.speakersService)
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Speakers.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(Strings.Speakers.shared.EMPTY_TITLE)
                .font(.headline)
                .foregroundColor(.secondary)
            Button(Strings.Speakers.shared.RETRY) {
                Task {
                    await viewModel.loadSpeakers(service: appViewModel.speakersService)
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(Strings.Speakers.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Speakers.shared.RETRY) {
                Task {
                    await viewModel.loadSpeakers(service: appViewModel.speakersService)
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Previews

#Preview("Speakers Content View") {
    SpeakersContentView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
