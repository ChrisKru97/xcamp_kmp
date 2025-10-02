import SwiftUI
import shared

struct CountdownView: View {
    let targetDate: Date
    @State private var timeRemaining: String = ""

    var body: some View {
        VStack {
            Text(StringsKt().countdown.title)
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

    private func updateTimeRemaining() {
        let now = Date()
        let difference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)

        if let day = difference.day, let hour = difference.hour, let minute = difference.minute, let second = difference.second {
            timeRemaining = String(format: "%02dd %02dh %02dm %02ds", day, hour, minute, second)
        } else {
            timeRemaining = "00d 00h 00m 00s"
        }
    }
}

#Preview {
    let dateFormatter = DateFormatter()
    CountdownView(targetDate:  dateFormatter.date(from: "07-18-2026") ?? Date())
}
