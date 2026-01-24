import SwiftUI
import shared

struct RatingView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
            }
        } else {
            contentView
        }
    }

    private var contentView: some View {
        ScrollView {
            Text("TODO")
        }
        .navigationTitle(Strings.Tabs.shared.RATING)
        .modifier(iOS16TabBarBackgroundModifier())
    }
}

#Preview {
    RatingView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
