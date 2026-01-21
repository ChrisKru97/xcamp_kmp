import SwiftUI
import shared

struct SpeakersView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SpeakersViewModel()

    var body: some View {
        NavigationView {
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
            .navigationTitle(Strings.Tabs.shared.SPEAKERS)
            .modifier(iOS16ToolbarBackgroundModifier())
            .task {
                await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
            }
        }
    }

    private func speakersList(_ speakers: [Speaker]) -> some View {
        List {
            ForEach(speakers, id: \.id) { speaker in
                NavigationLink(destination: SpeakerDetailView(speaker: speaker)) {
                    SpeakerListItem(speaker: speaker)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.md, bottom: Spacing.xs, trailing: Spacing.md))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .modifier(ListScrollContentBackgroundModifier())
        .refreshable {
            await viewModel.refreshSpeakers(service: appViewModel.getSpeakersService())
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
                    await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
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
                    await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - ViewModel

@MainActor
class SpeakersViewModel: ObservableObject {
    @Published private(set) var state: SpeakersState = .loading

    func loadSpeakers(service: SpeakersService) async {
        state = .loading
        do {
            let speakers = try await service.getAllSpeakers()
            // Data is already sorted by SQL: ORDER BY priority, name
            state = .loaded(speakers)
        } catch {
            state = .error
        }
    }

    func refreshSpeakers(service: SpeakersService) async {
        do {
            _ = try await service.refreshSpeakers()
            // On success, reload the speakers from local cache
            await loadSpeakers(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
        }
    }
}

enum SpeakersState {
    case loading
    case loaded([Speaker])
    case error
}

// MARK: - Speaker List Item

struct SpeakerListItem: View {
    let speaker: Speaker

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.md) {
                speakerImage
                speakerInfo
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }

    private var speakerImage: some View {
        AsyncImageWithFallback(
            url: speaker.imageUrlURL,
            fallbackIconName: "person.fill",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(Circle())
    }

    private var speakerInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(speaker.name)
                .font(.headline)
                .foregroundColor(.primary)
            // Use description_ to avoid conflict with Swift's built-in .description
            let speakerDescription = speaker.description_ ?? ""
            if !speakerDescription.isEmpty {
                Text(speakerDescription.prefix(100) + (speakerDescription.count > 100 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
        }
    }
}

// MARK: - Speaker Detail View

struct SpeakerDetailView: View {
    let speaker: Speaker

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                speakerHeroImage
                speakerContent
            }
        }
        .navigationTitle(speaker.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
    }

    private var speakerHeroImage: some View {
        HeroAsyncImageWithFallback(
            url: speaker.imageUrlURL,
            fallbackIconName: "person.fill",
            height: 300
        )
    }

    private var speakerContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = speaker.description_, !description.isEmpty {
                GlassCard {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(.top, -CornerRadius.large)
                .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.xl)
    }
}

// MARK: - iOS 16+ Toolbar Background Modifier

private struct iOS16ToolbarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarBackground(.hidden, for: .tabBar)
        } else {
            content
        }
    }
}

private struct ListScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

// MARK: - Previews

#Preview("Speakers View") {
    SpeakersView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Speaker List Item") {
    VStack {
        SpeakerListItem(speaker: Speaker(
            id: "test1",
            name: "Jan Novák",
            description: "Pastor a řečník",
            priority: 1,
            image: nil,
            imageUrl: nil
        ))
        SpeakerListItem(speaker: Speaker(
            id: "test2",
            name: "Marie Svobodová",
            description: nil,
            priority: 2,
            image: nil,
            imageUrl: nil
        ))
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Speaker Detail View") {
    NavigationView {
        SpeakerDetailView(speaker: Speaker(
            id: "test1",
            name: "Jan Novák",
            description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu.",
            priority: 1,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.dark)
}
