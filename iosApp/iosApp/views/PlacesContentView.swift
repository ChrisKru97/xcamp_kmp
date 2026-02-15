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
        EmptyView()
            .switchingContent(viewModel.state) { places, isStale in
                placesList(places, isStale: isStale)
            } error: { error in
                ErrorView(error: error) {
                    await viewModel.loadPlaces()
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
                    StaleDataBanner()
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
        .background(Color.background)
    }
}

// MARK: - Previews

#Preview("Places Content View") {
    PlacesContentView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
