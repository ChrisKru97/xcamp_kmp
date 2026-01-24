import SwiftUI
import shared

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Main View

struct SpeakersAndPlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTopTab = 0
    @State private var scrollOffset: CGFloat = 0

    private let tabTitles = [
        Strings.Tabs.shared.SPEAKERS,
        Strings.Tabs.shared.PLACES
    ]

    private var headerOpacity: Double {
        min(1, max(0, (scrollOffset + 50) / 50))
    }

    private var headerOffset: CGFloat {
        scrollOffset < 0 ? scrollOffset : 0
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
                    .navigationTitle("")
                    .navigationBarHidden(true)
            }
        } else {
            contentView
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            // Scroll-aware header
            VStack(spacing: 0) {
                // Title
                Text(Strings.Tabs.shared.SPEAKERS_AND_PLACES)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)

                // Segmented control
                Picker("", selection: $selectedTopTab) {
                    ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                        Text(title).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.sm)
            }
            .background(Color.background)
            .opacity(headerOpacity)
            .offset(y: headerOffset)
            .zIndex(1)

            Group {
                switch selectedTopTab {
                case 0:
                    SpeakersContentView(scrollOffset: $scrollOffset)
                case 1:
                    PlacesContentView(scrollOffset: $scrollOffset)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Speakers and Places View") {
    SpeakersAndPlacesView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
