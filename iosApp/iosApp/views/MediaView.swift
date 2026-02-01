import SwiftUI
import SwiftUIBackports
import shared

struct MediaView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        contentView
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mediaLinks: [MediaLink] {
        appViewModel.linksService.getMediaLinks()
    }
}

#Preview("Media View") {
    MediaView()
        .environmentObject(AppViewModel())
}
