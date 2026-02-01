import SwiftUI
import SwiftUIBackports
import shared

struct RatingView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        contentView
    }

    private var contentView: some View {
        ScrollView {
            Text(Strings.Rating.shared.COMING_SOON)
        }
        .navigationTitle(Strings.Tabs.shared.RATING)
    }
}

#Preview {
    RatingView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
