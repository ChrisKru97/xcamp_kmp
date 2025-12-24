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
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: Spacing.md) {
                    if showCountdown {
                        CountdownView()
                    }
                    
                    if !mainInfo.isEmpty {
                        MainInfoCard(infoText: mainInfo)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HomeHeaderView()
                }
            }
        }
        .navigationViewStyle(.automatic)
    }

    private var mainInfo: String {
        return overrideMainInfo ?? appViewModel.getRemoteConfigService().getMainInfo()
    }
    
    private var showCountdown: Bool {
        return overrideShowCountdown ?? appViewModel.getAppConfigService().shouldShowCountdown()
    }
}

@available(iOS 18, *)
#Preview("Upcoming event", traits: .sizeThatFitsLayout) {
    HomeView(overrideMainInfo: "Ahoj! Tohle je test\nNovy event", overrideShowCountdown: true)
        .environmentObject({
            let vm = AppViewModel()
            vm.appState = .limited
            return vm
        }())
}


@available(iOS 18, *)
#Preview("Ongoing event", traits: .sizeThatFitsLayout) {
    HomeView(overrideShowCountdown: false)
        .environmentObject({
            let vm = AppViewModel()
            vm.appState = .activeEvent
            return vm
        }())
}
