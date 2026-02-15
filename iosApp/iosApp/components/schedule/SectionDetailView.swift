import SwiftUI
import shared

struct SectionDetailView: View {
    let sectionUid: String
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel

    @State private var state: ContentState<shared.Section> = .loading
    @State private var isFavorite: Bool = false

    var scheduleService: ScheduleService { ServiceFactory.shared.getScheduleService() }

    var body: some View {
        EmptyView()
            .switchingContent(state) { section, _ in
                sectionContentView(section)
            } error: { error in
                ErrorView(error: error) {
                    await loadSection()
                }
            }
            .task {
                await loadSection()
            }
            .trackScreen(screenName: "session_detail")
            .onAppear {
                if case .loaded(let section) = state {
                    Analytics().logEvent(
                        name: AnalyticsEvents.CONTENT_VIEW,
                        parameters: [
                            AnalyticsParameters.PARAM_CONTENT_TYPE: "session",
                            AnalyticsParameters.PARAM_CONTENT_ID: section.uid,
                            AnalyticsParameters.PARAM_ENTITY_NAME: section.name
                        ]
                    )
                }
            }
    }

    private func loadSection() async {
        do {
            let result = try await scheduleService.getSectionById(uid: sectionUid)
            guard !Task.isCancelled else { return }
            if let section = result as? shared.Section {
                state = .loaded(section)
                isFavorite = section.favorite
            } else {
                state = .error(AppError.notFound)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error)
        }
    }

    private func sectionContentView(_ section: shared.Section) -> some View {
        ScrollView {
            contentSection(section)
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        isFavorite.toggle()
                        do {
                            try await scheduleService.toggleFavorite(sectionUid: section.uid, favorite: isFavorite)
                            if isFavorite {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
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
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isFavorite)
    }

    private func contentSection(_ section: shared.Section) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionTypeBadge(type: section.type)
                .padding(.horizontal, Spacing.md)

            SectionTimeCard(startTimeString: section.startTime, endTimeString: section.endTime)
                .padding(.horizontal, Spacing.md)

            if let placeUid = section.place {
                SectionPlaceCard(placeUid: placeUid)
                    .padding(.horizontal, Spacing.md)
            }

            if let speakerUids = section.speakers, !speakerUids.isEmpty {
                SectionSpeakersCard(speakerUids: speakerUids)
                    .padding(.horizontal, Spacing.md)
            }

            if let leaderUid = section.leader {
                SectionLeaderCard(leaderUid: leaderUid)
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
