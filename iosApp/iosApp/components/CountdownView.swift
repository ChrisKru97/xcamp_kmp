import SwiftUI
import shared

struct CountdownView: View {
    let targetDate: Date
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

    private func updateTimeRemaining() {
        let now = Date()
        let difference = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)
        
        let timeDiff = String(format: "%02d:%02d:%02d", difference.hour ?? 0, difference.minute ?? 0, difference.second ?? 0)
        
        guard let dayDifference = difference.day else {
            timeRemaining = timeDiff
            return
        }
        
        if(dayDifference > 0) {
            timeRemaining = "\(dayDifference) \(Strings.Countdown.shared.DAYS), \(timeDiff)"
        } else {
            timeRemaining = timeDiff
        }
    }
}

#Preview {
    let dateFormatter = DateFormatter()
    CountdownView(targetDate:  dateFormatter.date(from: "07-18-2026") ?? Date())
}
