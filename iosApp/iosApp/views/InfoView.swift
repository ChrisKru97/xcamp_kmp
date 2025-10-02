import SwiftUI
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("TODO")
            }
            .navigationTitle(Strings.Tabs.shared.INFO)
        }
    }
}
