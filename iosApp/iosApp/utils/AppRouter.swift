import SwiftUI
import NavigationBackport
import shared

enum DestinationType: String {
    case section
    case speaker
    case place
    case notificationSettings
}

struct NavigationDestination: Hashable {
    let uid: String
    let type: DestinationType?
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var paths: [AppTab: NBNavigationPath] = [:]

    func push(_ uid: String, type: DestinationType? = nil) {
        var currentPath = paths[selectedTab] ?? NBNavigationPath()
        currentPath.append(NavigationDestination(uid: uid, type: type))
        paths[selectedTab] = currentPath
    }
}
