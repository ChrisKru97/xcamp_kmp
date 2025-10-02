import SwiftUI
import shared

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(Strings.App.shared.TITLE)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if viewModel.shouldShowCountdown {
                        CountdownView(targetDate: viewModel.eventStartDate)
                    }
                }
                .padding()
            }
            .navigationTitle(Strings.Tabs.shared.HOME)
        }
    }
}

@MainActor class HomeViewModel: ObservableObject {
    @Published var shouldShowCountdown = true
    @Published var eventStartDate = Date()
}