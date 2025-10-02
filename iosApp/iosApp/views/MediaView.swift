import SwiftUI
import shared

struct MediaView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("TODO")
            }
            .navigationTitle(Strings.Tabs.shared.MEDIA)
        }
    }
}
