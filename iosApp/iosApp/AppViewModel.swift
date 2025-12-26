import SwiftUI
import shared

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .limited
    @Published var isLoading: Bool = true
    private var appConfigService: AppConfigService?
    private var remoteConfigService: RemoteConfigService?
    private var linksService: LinksService?

    func initializeApp() {
        let authService = AuthService()
        let appConfigService = getAppConfigService()

        let appInitializer = AppInitializer(
            appConfigService: appConfigService,
            authService: authService
        )

        Task {
            do {
                try await appInitializer.initialize()
                await MainActor.run {
                    appState = appConfigService.getAppState()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    func getAppConfigService() -> AppConfigService {
        guard let appConfigService = appConfigService else {
            let newAppConfigService = AppConfigService(remoteConfigService: getRemoteConfigService())
            appConfigService = newAppConfigService
            return newAppConfigService
        }
        return appConfigService
    }

    func getRemoteConfigService() -> RemoteConfigService {
        guard let remoteConfigService = remoteConfigService else {
            let newRemoteConfigService = RemoteConfigService()
            remoteConfigService = newRemoteConfigService
            return newRemoteConfigService
        }
        return remoteConfigService
    }

    func getLinksService() -> LinksService {
        guard let linksService = linksService else {
            let newLinksService = LinksService(
                remoteConfigService: getRemoteConfigService()
            )
            self.linksService = newLinksService
            return newLinksService
        }
        return linksService
    }
}
