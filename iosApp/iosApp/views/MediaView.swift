import SwiftUI
import shared

struct MediaView: View {
    @EnvironmentObject var appViewModel: AppViewModel

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
        ScrollView {
            MediaGrid(links: mediaLinks)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxl)
        }
        .background(Color.background)
        .navigationTitle(Strings.Tabs.shared.MEDIA)
        .modifier(iOS16TabBarBackgroundModifier())
    }

    private var mediaLinks: [MediaLink] {
        appViewModel.getLinksService().getMediaLinks()
    }
}

#Preview("Media View") {
    MediaView()
        .environmentObject(AppViewModel())
}
