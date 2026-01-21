import SwiftUI
import shared

struct PlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = PlacesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()

                switch viewModel.state {
                case .loading:
                    loadingView
                case .loaded(let places):
                    if places.isEmpty {
                        emptyView
                    } else {
                        placesList(places)
                    }
                case .error:
                    errorView
                }
            }
            .navigationTitle(Strings.Tabs.shared.PLACES)
            .task {
                await viewModel.loadPlaces(service: appViewModel.getPlacesService())
            }
        }
    }

    private func placesList(_ places: [Place]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(places, id: \.id) { place in
                    NavigationLink(destination: PlaceDetailView(place: place)) {
                        PlaceListItem(place: place)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshPlaces(service: appViewModel.getPlacesService())
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Places.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text(Strings.Places.shared.EMPTY_TITLE)
                .font(.headline)
                .foregroundColor(.secondary)
            Button(Strings.Places.shared.RETRY) {
                Task {
                    await viewModel.loadPlaces(service: appViewModel.getPlacesService())
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
            Text(Strings.Places.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Places.shared.RETRY) {
                Task {
                    await viewModel.loadPlaces(service: appViewModel.getPlacesService())
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - ViewModel

@MainActor
class PlacesViewModel: ObservableObject {
    @Published private(set) var state: PlacesState = .loading

    func loadPlaces(service: PlacesService) async {
        state = .loading
        do {
            let places = try await service.getAllPlaces()
            state = .loaded(places)
        } catch {
            state = .error
        }
    }

    func refreshPlaces(service: PlacesService) async {
        do {
            _ = try await service.refreshPlaces()
            // On success, reload the places from local cache
            await loadPlaces(service: service)
        } catch {
            // If refresh fails, keep showing existing data silently
        }
    }
}

enum PlacesState {
    case loading
    case loaded([Place])
    case error
}

// MARK: - Place List Item

struct PlaceListItem: View {
    let place: Place

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.md) {
                placeImage
                placeInfo
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }

    private var imageUrl: URL? {
        guard let urlString = place.imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private var placeImage: some View {
        AsyncImageWithFallback(
            url: imageUrl,
            fallbackIconName: "photo",
            size: CGSize(width: 80, height: 80)
        )
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    private var placeInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(place.name)
                .font(.headline)
                .foregroundColor(.primary)
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = place.description_, !description.isEmpty {
                Text(description.prefix(100) + (description.count > 100 ? "..." : ""))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            if place.latitude != nil && place.longitude != nil {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(Strings.Places.shared.SHOW_ON_MAP)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Place Detail View

struct PlaceDetailView: View {
    let place: Place

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                placeHeroImage
                placeContent
            }
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
    }

    private var imageUrl: URL? {
        guard let urlString = place.imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private var placeHeroImage: some View {
        HeroAsyncImageWithFallback(
            url: imageUrl,
            fallbackIconName: "photo",
            height: 250
        )
    }

    private var placeContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Use description_ to avoid conflict with Swift's built-in .description
            if let description = place.description_, !description.isEmpty {
                GlassCard {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(.top, -CornerRadius.large)
                .padding(.horizontal, Spacing.md)
            }

            if let lat = place.latitude, let lon = place.longitude {
                Button {
                    openInMaps(latitude: lat.doubleValue, longitude: lon.doubleValue, name: place.name)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text(Strings.Places.shared.OPEN_IN_MAPS)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.xl)
    }

    private func openInMaps(latitude: Double, longitude: Double, name: String) {
        let region = "ll=\(latitude),\(longitude)"
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "http://maps.apple.com/?\(region)&q=\(encodedName)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Previews

#Preview("Places View") {
    PlacesView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Place List Item") {
    VStack {
        PlaceListItem(place: Place(
            id: "test",
            name: "Test Place",
            description: "This is a test description for the place",
            priority: 1,
            latitude: 50.0,
            longitude: 14.0,
            image: nil,
            imageUrl: nil
        ))
        PlaceListItem(place: Place(
            id: "test2",
            name: "Another Place",
            description: nil,
            priority: 2,
            latitude: nil,
            longitude: nil,
            image: nil,
            imageUrl: nil
        ))
    }
    .padding()
    .background(Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Place Detail View") {
    NavigationView {
        PlaceDetailView(place: Place(
            id: "test",
            name: "Test Place",
            description: "This is a longer description that should wrap nicely. It can contain multiple lines of text describing the place in detail.",
            priority: 1,
            latitude: 50.0,
            longitude: 14.0,
            image: nil,
            imageUrl: nil
        ))
    }
    .preferredColorScheme(.dark)
}
