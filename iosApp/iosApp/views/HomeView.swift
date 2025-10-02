import SwiftUI
import shared

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text(appViewModel.mainInfo)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Start Date: \(appViewModel.startDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if viewModel.shouldShowCountdown {
                        CountdownView(targetDate: viewModel.eventStartDate)
                    }
                }
                .padding()
            }
            .navigationTitle(StringsKt().titles.home)
        }
    }
}

@MainActor class HomeViewModel: ObservableObject {
    @Published var shouldShowCountdown = true
    @Published var shouldShowQRButton = false
    @Published var shouldShowSchedulePreview = true
    @Published var eventStartDate = Date()

    func refresh() async {
        // TODO: Load data from KMP repositories
    }
}