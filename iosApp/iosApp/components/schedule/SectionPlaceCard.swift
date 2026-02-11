import SwiftUI
import shared

enum SectionPlaceCardState {
    case loading
    case loaded(Place)
    case error
    case notFound
}

struct SectionPlaceCard: View {
    let placeUid: String

    var placesService: PlacesService { ServiceFactory.shared.getPlacesService() }

    @EnvironmentObject var router: AppRouter
    @State private var state: SectionPlaceCardState = .loading

    var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            case .loaded(let place):
                Button {
                    router.push(place.uid, type: .place)
                } label: {
                    cardContent(place.name)
                }
                .glassButton()
            case .error, .notFound:
                placeholderCard
            }
        }
        .task {
            await loadPlace()
        }
    }

    @ViewBuilder
    private var placeholderCard: some View {
        HStack {
            labelSection
            Spacer()
            Text(Strings.ScheduleDetail.shared.PLACE_UNKNOWN)
                .font(.body)
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(Spacing.md)
        .card()
        .opacity(0.6)
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
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    state = .loaded(place)
                }
            } else {
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    state = .notFound
                }
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                state = .notFound
            }
        }
    }
}

#Preview {
    SectionPlaceCard(placeUid: "test-place-id")
        .environmentObject(AppRouter())
}
