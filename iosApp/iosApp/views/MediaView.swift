import SwiftUI
import shared

struct MediaView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(mediaLinks, id: \.type) { link in
                        MediaLinkCard(link: link)
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.background)
            .navigationTitle(Strings.Tabs.shared.MEDIA)
        }
    }

    private var mediaLinks: [MediaLink] { appViewModel.getLinksService().getMediaLinks() }
}

@available(iOS 18, *)
#Preview("Media View", traits: .sizeThatFitsLayout) {
    MediaView()
        .environmentObject(AppViewModel())
}
