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
            .task {
                await viewModel.loadSpeakers(service: appViewModel.getSpeakersService())
            }
        }
    }

    private func speakersList(_ speakers: [Speaker]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(speakers, id: \.id) { speaker in
                    NavigationLink(destination: SpeakerDetailView(speaker: speaker)) {
                        SpeakerListItem(speaker: speaker)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
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
        AsyncImage(url: URL(string: speaker.imageUrl ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure(_):
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
            case .empty:
                ProgressView()
            @unknown default:
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }

    private var speakerInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(speaker.name)
                .font(.headline)
                .foregroundColor(.primary)
            let description = speaker.description
            if !description.isEmpty {
                Text(description.prefix(100) + (description.count > 100 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
        AsyncImage(url: URL(string: speaker.imageUrl ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure(_):
                ZStack {
                    Color.secondary.opacity(0.3)
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            case .empty:
                ZStack {
                    Color.secondary.opacity(0.3)
                    ProgressView()
                }
            @unknown default:
                ZStack {
                    Color.secondary.opacity(0.3)
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var speakerContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            let description = speaker.description
            if !description.isEmpty {
                GlassCard {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding(.top, -CornerRadius.large)
                .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.md)
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
            id: 1,
            uid: "test",
            name: "Jan Novák",
            description: "Pastor a řečník",
            priority: 1,
            image: nil,
            imageUrl: nil
        ))
        SpeakerListItem(speaker: Speaker(
            id: 2,
            uid: "test2",
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
            id: 1,
            uid: "test",
            name: "Jan Novák",
            description: "Pastor a řečník s mnoha lety zkušeností. Slouží církvi a víře již více než 20 let. Jeho posláním je šířit evangelium a pomáhat lidem najít cestu k Bohu.",
            priority: 1,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.dark)
}
