import SwiftUI
import shared

struct InfoView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("INFO TODO")
            }
            .navigationTitle("Informace")
        }
    }
}
