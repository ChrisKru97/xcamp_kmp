import SwiftUI
import shared

struct SpeakersView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        SpeakersContentView()
            .navigationTitle(Strings.Tabs.shared.SPEAKERS)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Speakers View") {
    SpeakersView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
