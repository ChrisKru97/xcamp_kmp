import SwiftUI
import shared

struct PlacesContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = PlacesViewModel()
    @Binding var scrollOffset: CGFloat

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
        .task {
            await viewModel.loadPlaces(service: appViewModel.getPlacesService())
        }
    }

    private func placesList(_ places: [Place]) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(places, id: \.id) { place in
                    NavigationLink(destination: PlaceDetailView(place: place)) {
                        PlaceListItem(place: place)
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
            await viewModel.refreshPlaces(service: appViewModel.getPlacesService())
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .accessibilityLabel(Strings.Places.shared.LOADING)
            Text(Strings.Places.shared.LOADING)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Places.shared.LOADING)
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text(Strings.Places.shared.EMPTY_TITLE)
                .font(.headline)
                .foregroundColor(.secondary)
            Button(Strings.Places.shared.RETRY) {
                Task {
                    await viewModel.loadPlaces(service: appViewModel.getPlacesService())
                }
            }
            .buttonStyle(.bordered)
            .accessibilityHint(Strings.Places.shared.RETRY_HINT)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Places.shared.EMPTY_TITLE)
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .accessibilityHidden(true)
            Text(Strings.Places.shared.ERROR_TITLE)
                .font(.headline)
            Button(Strings.Places.shared.RETRY) {
                Task {
                    await viewModel.loadPlaces(service: appViewModel.getPlacesService())
                }
            }
            .buttonStyle(.bordered)
            .accessibilityHint(Strings.Places.shared.RETRY_HINT)
        }
        .accessibilityElement()
        .accessibilityLabel(Strings.Places.shared.ERROR_TITLE)
    }
}

// MARK: - Previews

#Preview("Places Content View") {
    NavigationStack {
        PlacesContentView(scrollOffset: .constant(0))
    }
    .environmentObject(AppViewModel())
    .preferredColorScheme(.dark)
}
