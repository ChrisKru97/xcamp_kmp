import SwiftUI
import shared

struct SectionDetailView: View {
    let section: shared.Section
    let service: ScheduleService
    let onFavoriteToggled: () -> Void

    @State private var isFavorite: Bool

    init(section: shared.Section, service: ScheduleService, onFavoriteToggled: @escaping () -> Void) {
        self.section = section
        self.service = service
        self.onFavoriteToggled = onFavoriteToggled
        self._isFavorite = State(initialValue: section.favorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SectionDetailHero(type: section.type)
                contentSection
            }
        }
        .navigationTitle(section.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .hideTabBar()
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
            SectionTimeCard(startTimeString: section.startTime, endTimeString: section.endTime)
                .padding(.top, -CornerRadius.large)
                .padding(.horizontal, Spacing.md)

            let description = section.description
            if !description.isEmpty {
                SectionDescriptionCard(description: description)
                    .padding(.horizontal, Spacing.md)
            }

            Spacer(minLength: Spacing.xxl)
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - Previews

#Preview("Section Detail Hero - Main") {
    SectionDetailHero(type: .main)
        .preferredColorScheme(.dark)
}

#Preview("Section Detail Hero - Gospel") {
    SectionDetailHero(type: .gospel)
        .preferredColorScheme(.light)
}

#Preview("Section Time Card") {
    SectionTimeCard(startTimeString: "09:00", endTimeString: "10:30")
        .padding()
        .background(Color.background)
        .preferredColorScheme(.dark)
}

#Preview("Section Description Card") {
    SectionDescriptionCard(description: "Ranní chvály a hlavní téma dne.")
        .padding()
        .background(Color.background)
        .preferredColorScheme(.light)
}
