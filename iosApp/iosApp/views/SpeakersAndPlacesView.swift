import SwiftUI
import shared

// MARK: - Main View

private enum Tab: CaseIterable {
    case speakers, places

    var title: String {
        switch self {
            case .speakers: Strings.Tabs.shared.SPEAKERS
            case .places: Strings.Tabs.shared.PLACES
        }
    }
}

struct SpeakersAndPlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab: Tab = .speakers

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
            }
        } else {
            contentView
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.background)

            switch selectedTab {
            case .speakers:
                SpeakersContentView()
            case .places:
                PlacesContentView()
            }
        }
        .navigationTitle(Strings.Tabs.shared.SPEAKERS_AND_PLACES)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarBackground()
    }
}

// MARK: - Previews

#Preview("Speakers and Places View") {
    SpeakersAndPlacesView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
