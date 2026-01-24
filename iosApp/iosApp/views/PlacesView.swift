import SwiftUI
import shared

struct PlacesView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var scrollOffset: CGFloat = 0

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
        PlacesContentView(scrollOffset: $scrollOffset)
            .navigationTitle(Strings.Tabs.shared.PLACES)
            .modifier(iOS16ToolbarBackgroundModifier())
    }
}

// MARK: - iOS 16+ Toolbar Background Modifier

private struct iOS16ToolbarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
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
