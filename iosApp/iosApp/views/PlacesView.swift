import SwiftUI
import shared

struct PlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("TODO")
            }
            .navigationTitle(Strings.Tabs.shared.PLACES)
        }
    }
}
