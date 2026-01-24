import SwiftUI
import shared

struct SpeakersContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SpeakersViewModel()
    @Binding var scrollOffset: CGFloat

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

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
            await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
        }
    }

    private func speakersList(_ speakers: [Speaker]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(speakers, id: \.id) { speaker in
                    NavigationLink(destination: SpeakerDetailView(speaker: speaker)) {
                        SpeakerListItem(speaker: speaker)
                            .equatable()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
            .coordinateSpace(name: "scrollView")
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self,
                                  value: geometry.frame(in: .named("scrollView")).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                scrollOffset = offset
            }
        }
        .refreshable {
            await viewModel.refreshSpeakers(service: appViewModel.getSpeakersService())
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .accessibilityLabel(Strings.Speakers.shared.LOADING)
            Text(Strings.Speakers.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Speakers.shared.LOADING)
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text(Strings.Speakers.shared.EMPTY_TITLE)
                .font(.headline)
                .foregroundColor(.secondary)
            Button(Strings.Speakers.shared.RETRY) {
                Task {
                    await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
                }
            }
            .buttonStyle(.bordered)
            .accessibilityHint(Strings.Speakers.shared.RETRY_HINT)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Speakers.shared.EMPTY_TITLE)
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            Text(Strings.Speakers.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Speakers.shared.RETRY) {
                Task {
                    await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
                }
            }
            .buttonStyle(.bordered)
            .accessibilityHint(Strings.Speakers.shared.RETRY_HINT)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Speakers.shared.ERROR_TITLE)
    }
}

// MARK: - Previews

#Preview("Speakers Content View") {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SpeakersContentView(scrollOffset: .constant(0))
        }
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
    } else {
        SpeakersContentView(scrollOffset: .constant(0))
            .environmentObject(AppViewModel())
            .preferredColorScheme(.dark)
    }
}
