import SwiftUI
import NavigationBackport
import shared

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var paths: [AppTab: NBNavigationPath] = [:]

    var path: Binding<NBNavigationPath> {
        Binding(
            get: { self.paths[self.selectedTab] ?? NBNavigationPath() },
            set: { self.paths[self.selectedTab] = $0 }
        )
    }

    func push(_ uid: String) {
        var currentPath = paths[selectedTab] ?? NBNavigationPath()
        currentPath.append(uid)
        paths[selectedTab] = currentPath
    }

    func pop() {
        var currentPath = paths[selectedTab] ?? NBNavigationPath()
        if !currentPath.isEmpty {
            currentPath.removeLast()
            paths[selectedTab] = currentPath
        }
    }

    func popToRoot() {
        paths[selectedTab] = NBNavigationPath()
    }

    var canGoBack: Bool {
        !(paths[selectedTab]?.isEmpty ?? true)
    }
}
