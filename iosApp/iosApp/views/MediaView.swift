import SwiftUI
import shared

struct MediaView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                MediaGrid(links: mediaLinks)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xxl)
            }
            .background(Color.background)
            .navigationTitle(Strings.Tabs.shared.MEDIA)
        }
    }

    private var mediaLinks: [MediaLink] {
        appViewModel.getLinksService().getMediaLinks()
    }
}

#Preview("Media View") {
    MediaView()
        .environmentObject(AppViewModel())
}
