import SwiftUI
import shared

struct RatingView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                Text("TODO")
            }
            .navigationTitle(Strings.Tabs.shared.RATING)
        }
    }
}

#Preview {
    RatingView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
