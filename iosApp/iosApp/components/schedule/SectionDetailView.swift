import SwiftUI
import shared

struct SectionDetailView: View {
    let sectionUid: String
    let onFavoriteToggled: () -> Void

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
            section = try? await ServiceFactory.shared.getScheduleService().getSectionById(uid: sectionUid)
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
                    Task {
                        isFavorite.toggle()
                        do {
                            try await ServiceFactory.shared.getScheduleService().toggleFavorite(sectionUid: section.uid, favorite: isFavorite)
                            if isFavorite {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            onFavoriteToggled()
                        } catch {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            isFavorite.toggle()
                        }
                    }
                }) {
                    favoriteIcon
                }
                .glassButton()
            }
        }
    }

    @ViewBuilder
    private var favoriteIcon: some View {
        Image(systemName: isFavorite ? "star.fill" : "star")
            .foregroundColor(isFavorite ? .yellow : .secondary)
            .animation(.spring(response: 2, dampingFraction: 0.75), value: isFavorite)
    }

    private func contentSection(_ section: shared.Section) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTypeBadge(type: section.type)
                .padding(.horizontal, Spacing.md)

            SectionTimeCard(startTimeString: section.startTime, endTimeString: section.endTime)
                .padding(.horizontal, Spacing.md)

            if let placeUid = section.place {
                SectionPlaceCard(placeUid: placeUid, placesService: ServiceFactory.shared.getPlacesService())
                    .padding(.horizontal, Spacing.md)
            }

            if let speakerUids = section.speakers, !speakerUids.isEmpty {
                SectionSpeakersCard(speakerUids: speakerUids, speakersService: ServiceFactory.shared.getSpeakersService())
                    .padding(.horizontal, Spacing.md)
            }

            if let leaderUid = section.leader {
                SectionLeaderCard(leaderUid: leaderUid, speakersService: ServiceFactory.shared.getSpeakersService())
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
