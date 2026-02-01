import SwiftUI
import SwiftUIBackports
import shared

struct PlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        contentView
    }

    private var contentView: some View {
        PlacesContentView()
            .navigationTitle(Strings.Tabs.shared.PLACES)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Places View") {
    PlacesView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
