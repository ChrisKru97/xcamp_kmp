import SwiftUI
import NavigationBackport
import shared

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var paths: [AppTab: NBNavigationPath] = [:]

    func push(_ uid: String) {
        var currentPath = paths[selectedTab] ?? NBNavigationPath()
        currentPath.append(uid)
        paths[selectedTab] = currentPath
    }
}
