import SwiftUI
import shared

struct SectionPlaceCard: View {
    let placeUid: String

    var placesService: PlacesService { ServiceFactory.shared.getPlacesService() }

    @EnvironmentObject var router: AppRouter
    @State private var state: ContentState<Place?> = .loading

    var body: some View {
        bodyContent
            .task {
                await loadPlace()
            }
    }

    @ViewBuilder
    private var bodyContent: some View {
        switchingContent(state, loading: { CardLoadingView() }) { place, _ in
            if let place = place {
                Button {
                    router.push(place.uid, type: .place)
                } label: {
                    cardContent(place.name)
                }
                .glassButton()
            } else {
                CardUnavailableView(message: "Place Not Available")
            }
        } error: { _ in
            CardUnavailableView(message: "Unknown Place")
        }
    }

    private func cardContent(_ placeName: String) -> some View {
            HStack {
                labelSection
                Spacer()
                Text(placeName)
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.padding(Spacing.md)
    }

    private var labelSection: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.secondary)
            Text(Strings.ScheduleDetail.shared.DETAIL_PLACE)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func loadPlace() async {
        do {
            let result = try await placesService.getPlaceById(uid: placeUid)
            guard !Task.isCancelled else { return }
            if let place = result as? Place {
                state = .loaded(place)
            } else {
                state = .error(AppError.notFound)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }
}

#Preview {
    SectionPlaceCard(placeUid: "test-place-id")
        .environmentObject(AppRouter())
}
