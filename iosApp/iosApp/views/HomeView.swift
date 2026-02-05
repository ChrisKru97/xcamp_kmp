import SwiftUI
import shared

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let overrideMainInfo: String?
    let overrideShowCountdown: Bool?

    init(overrideMainInfo: String? = nil, overrideShowCountdown: Bool? = nil) {
        self.overrideMainInfo = overrideMainInfo
        self.overrideShowCountdown = overrideShowCountdown
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HomeHeaderView()
                .padding(.bottom, Spacing.sm)

            if showCountdown {
                CountdownView()
            }

            if !mainInfo.isEmpty {
                MainInfoCard(infoText: mainInfo)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
    }

    private var mainInfo: String {
        return overrideMainInfo ?? appViewModel.remoteConfigService.getMainInfo()
    }

    private var showCountdown: Bool {
        return overrideShowCountdown ?? appViewModel.appConfigService.shouldShowCountdown()
    }
}

#Preview("Upcoming event") {
    HomeView(overrideMainInfo: "Ahoj! Tohle je test\nNovy event", overrideShowCountdown: true)
        .environmentObject({
            let vm = AppViewModel()
            vm.appState = .limited
            return vm
        }())
}


#Preview("Ongoing event") {
    HomeView(overrideShowCountdown: false)
        .environmentObject({
            let vm = AppViewModel()
            vm.appState = .activeEvent
            return vm
        }())
}
