import SwiftUI
import shared

struct RatingView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("INFO TODO")
            }
            .navigationTitle("Hodnocení")
        }
    }
}
