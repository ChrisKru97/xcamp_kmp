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
                speakersList(speakers)
            case .error:
                errorView
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

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Speakers.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    await viewModel.loadSpeakers()
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
