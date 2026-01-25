import SwiftUI
import shared

struct CountdownView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var timeRemaining: String = ""

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(Strings.Countdown.shared.TITLE)
            Text(timeRemaining)
                .font(.title)
                .fontWeight(.semibold)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    timeRemaining = countdownCalculator.getTimeRemaining()
                }
        }
        .onAppear {
            timeRemaining = countdownCalculator.getTimeRemaining()
        }
        .padding()
        .backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
    }

    private var countdownCalculator: CountdownCalculator {
        let targetDate = appViewModel.remoteConfigService.getStartDate()
        return CountdownUtils.shared.createCountdownCalculator(dateString: targetDate)
    }
}

#Preview("Countdown") {
    CountdownView()
        .environmentObject(AppViewModel())
        .padding()
        .background(Color.background)
}
