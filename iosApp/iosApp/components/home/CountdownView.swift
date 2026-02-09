import SwiftUI
import shared

struct CountdownView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var days: Int = 0
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    private func updateCountdown() {
        let targetDateString = appViewModel.remoteConfigService.getStartDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let targetDate = formatter.date(from: targetDateString) else {
            days = 0; hours = 0; minutes = 0; seconds = 0; return
        }
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)

        withAnimation(.linear(duration: 0.3)) {
            days = max(0, components.day ?? 0)
            hours = max(0, components.hour ?? 0)
            minutes = max(0, components.minute ?? 0)
            seconds = max(0, components.second ?? 0)
        }
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text(Strings.Countdown.shared.TITLE)
            HStack(spacing: 0) {
                AnimatedNumberText(value: days)
                Text(" " + CountdownUtilsKt.getDaysPluralization(days: Int32(days)) + ", ")
                AnimatedNumberText(value: hours)
                Text(":")
                AnimatedNumberText(value: minutes)
                Text(":")
                AnimatedNumberText(value: seconds)
            }
            .font(.title)
            .modifier(FontWeightSemiboldModifier())
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                updateCountdown()
            }
        }
        .onAppear {
            updateCountdown()
        }
        .padding()
    }

    @ViewBuilder
    private func AnimatedNumberText(value: Int,) -> some View {
        Text(String(format: "%02d", value))
            .backport.contentTransition(.numericText(value: Double(value)))
            .monospacedDigit()
    }
}

private struct FontWeightSemiboldModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.fontWeight(.semibold)
        } else {
            content
        }
    }
}

#Preview("Countdown") {
    CountdownView()
        .environmentObject(AppViewModel())
        .padding()
        .background(Color.background)
}
