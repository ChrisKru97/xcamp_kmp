import SwiftUI
import shared

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(Strings.App.shared.TITLE)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if shouldShowCountdown {
                        CountdownView(targetDate: eventStartDate)
                    }
                }
                .padding()
            }
            .navigationTitle(Strings.Tabs.shared.HOME)
        }
    }

    private var shouldShowCountdown: Bool {
        appViewModel.appState == .preEvent || appViewModel.appState == .limited
    }

    private var eventStartDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = appViewModel.getRemoteConfigService().getStartDate()
        return formatter.date(from: startDateString) ?? Date()
    }
}