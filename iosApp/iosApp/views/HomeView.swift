import SwiftUI
import shared

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.shouldShowCountdown {
                        CountdownView(targetDate: viewModel.eventStartDate)
                    }
                }
                .padding()
            }
            .navigationTitle("XcamP")
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