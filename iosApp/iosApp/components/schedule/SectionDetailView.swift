import SwiftUI
import shared

struct SectionDetailView: View {
    let section: shared.Section
    let service: ScheduleService
    let placesService: PlacesService
    let speakersService: SpeakersService
    let onFavoriteToggled: () -> Void

    @State private var isFavorite: Bool

    init(section: shared.Section, service: ScheduleService, placesService: PlacesService, speakersService: SpeakersService, onFavoriteToggled: @escaping () -> Void) {
        self.section = section
        self.service = service
        self.placesService = placesService
        self.speakersService = speakersService
        self.onFavoriteToggled = onFavoriteToggled
        self._isFavorite = State(initialValue: section.favorite)
    }

    var body: some View {
        ScrollView {
            contentSection
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        isFavorite.toggle()
                        try? await service.toggleFavorite(sectionUid: section.uid, favorite: isFavorite)
                        onFavoriteToggled()
                    }
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .secondary)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTypeBadge(type: section.type)
                .padding(.horizontal, Spacing.md)

            SectionTimeCard(startTimeString: section.startTime, endTimeString: section.endTime)
                .padding(.horizontal, Spacing.md)

            if let placeUid = section.place {
                SectionPlaceCard(placeUid: placeUid, placesService: placesService)
                    .padding(.horizontal, Spacing.md)
            }

            if let speakerUids = section.speakers, !speakerUids.isEmpty {
                SectionSpeakersCard(speakerUids: speakerUids, speakersService: speakersService)
                    .padding(.horizontal, Spacing.md)
            }

            if let leaderUid = section.leader {
                SectionLeaderCard(leaderUid: leaderUid, speakersService: speakersService)
                    .padding(.horizontal, Spacing.md)
            }

            if let description = section.description_, !description.isEmpty {
                SectionDescriptionCard(description: description)
                    .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.md)
    }
}
