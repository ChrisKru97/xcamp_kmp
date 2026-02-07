import SwiftUI
import shared

struct SectionPlaceCard: View {
    let placeUid: String
    let placesService: PlacesService

    @EnvironmentObject var router: AppRouter
    @State private var place: Place?

    var body: some View {
        Group {
            if let place = place {
                Button {
                    router.push(place.uid)
                } label: {
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
            .card()
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
