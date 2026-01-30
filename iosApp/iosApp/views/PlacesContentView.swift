import SwiftUI
import shared

struct PlacesContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = PlacesViewModel()

    @State private var showFullscreen = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
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
        .sheet(isPresented: $showFullscreen) {
            FullscreenImageView(
                imageURL: viewModel.arealImageURL,
                isPresented: $showFullscreen
            )
        }
        .task {
            await viewModel.loadPlaces(service: appViewModel.placesService)
        }
    }

    private func placesList(_ places: [Place]) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                ArealHeroSection(imageURL: viewModel.arealImageURL) {
                    showFullscreen = true
                }

                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(places, id: \.id) { place in
                        NavigationLink(destination: PlaceDetailView(place: place)) {
                            PlaceListItem(place: place)
                                .equatable()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshPlaces(service: appViewModel.placesService)
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
                    await viewModel.loadPlaces(service: appViewModel.placesService)
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
                    await viewModel.loadPlaces(service: appViewModel.placesService)
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Previews

#Preview("Places Content View") {
    PlacesContentView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
