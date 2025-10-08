import SwiftUI
import shared

struct CountdownView: View {
    let targetDateString: String
    @State private var timeRemaining: String = ""

    var body: some View {
        VStack {
            Text(Strings.Countdown.shared.TITLE)
                .font(.headline)
            Text(timeRemaining)
                .font(.largeTitle)
                .onAppear(perform: updateTimeRemaining)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    updateTimeRemaining()
                }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }

    private var countdownCalculator: CountdownCalculator {
        return CountdownUtils.shared.createCountdownCalculator(dateString: targetDateString)
    }

    private func updateTimeRemaining() {
        timeRemaining = countdownCalculator.getTimeRemaining()
    }
}

#Preview {
    CountdownView(targetDateString: "2026-07-18")
}
