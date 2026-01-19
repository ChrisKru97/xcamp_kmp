import Foundation

extension DateFormatter {
    /// Shared date formatter for time formatting (HH:mm in Czech locale)
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "cs_CZ")
        return formatter
    }()

    /// Format milliseconds since epoch to time string (HH:mm)
    static func formatTime(from millis: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        return timeFormatter.string(from: date)
    }
}
