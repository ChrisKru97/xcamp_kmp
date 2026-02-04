import SwiftUI
import shared

struct SectionPlaceCard: View {
    let placeUid: String
    let placesService: PlacesService

    @State private var place: Place?

    var body: some View {
        Group {
            if let place = place {
                NavigationLink(destination: PlaceDetailView(place: place)) {
                    cardContent(place.name)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .task {
            place = try? await placesService.getPlaceById(uid: placeUid)
        }
    }

    private func cardContent(_ placeName: String) -> some View {
        GlassCard {
            HStack {
                labelSection
                Spacer()
                Text(placeName)
                    .font(.body)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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
}
