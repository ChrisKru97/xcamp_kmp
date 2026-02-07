import SwiftUI
import shared

struct SectionDetailView: View {
    let sectionUid: String
    let onFavoriteToggled: () -> Void

    @Environment(\.scheduleService) private var scheduleService
    @Environment(\.placesService) private var placesService
    @Environment(\.speakersService) private var speakersService

    @State private var section: shared.Section?
    @State private var isFavorite: Bool = false

    var body: some View {
        Group {
            if let section {
                sectionContentView(section)
            } else {
                ProgressView()
            }
        }
        .task {
            section = try? await scheduleService.getSectionById(uid: sectionUid)
            if let section = section {
                isFavorite = section.favorite
            }
        }
    }

    private func sectionContentView(_ section: shared.Section) -> some View {
        ScrollView {
            contentSection(section)
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    Task {
                        isFavorite.toggle()
                        try? await scheduleService.toggleFavorite(sectionUid: section.uid, favorite: isFavorite)
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

    private func contentSection(_ section: shared.Section) -> some View {
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
