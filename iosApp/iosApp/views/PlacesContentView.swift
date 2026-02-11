import SwiftUI
import shared

struct PlacesContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = PlacesViewModel()

    @State private var showFullscreen = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        Group {
            switch viewModel.state {
            case .initial, .loading:
                loadingView
            case .loaded(let places, let isStale):
                placesList(places, isStale: isStale)
            case .refreshing(let places):
                placesList(places, isStale: false)
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
            await viewModel.loadPlaces()
        }
    }

    private func placesList(_ places: [Place], isStale: Bool) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                ArealHeroSection(imageURL: viewModel.arealImageURL) {
                    showFullscreen = true
                }

                if isStale {
                    staleDataIndicator
                }

                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(places, id: \.uid) { place in
                        Button {
                            router.push(place.uid, type: .place)
                        } label: {
                            PlaceListItem(place: place)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .refreshable {
            await viewModel.refreshPlaces()
        }
    }

    private var staleDataIndicator: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.orange)
            Text(Strings.Places.shared.ERROR_TITLE)
                .font(.caption)
                .foregroundColor(.orange)
        }
        .padding(Spacing.sm)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(Spacing.sm)
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Places.shared.LOADING)
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
            Text(Strings.Places.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Places.shared.RETRY) {
                Task {
                    await viewModel.loadPlaces()
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
