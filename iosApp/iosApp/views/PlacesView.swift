import SwiftUI
import shared

struct PlacesView: View {
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
        PlacesContentView()
            .navigationTitle(Strings.Tabs.shared.PLACES)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(iOS16ToolbarBackgroundModifier())
    }
}

// MARK: - iOS 16+ Toolbar Background Modifier

private struct iOS16ToolbarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.hidden, for: .tabBar)
        } else {
            content
        }
    }
}

// MARK: - Previews

#Preview("Places View") {
    PlacesView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
