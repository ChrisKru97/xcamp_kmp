import SwiftUI
import shared

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
            Text(Strings.Common.shared.LOADING)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let retry: (() async -> Void)?

    init(retry: (() async -> Void)? = nil) {
        self.retry = retry
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(Strings.Common.shared.ERROR_TITLE)
                .font(.headline)
            if let retry {
                Button(Strings.Common.shared.RETRY) {
                    Task { await retry() }
                }
                .glassButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StaleDataBanner: View {
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(Strings.Common.shared.STALE_DATA)
        }
        .font(.caption)
        .foregroundColor(.orange)
        .padding(Spacing.sm)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(Spacing.sm)
    }
}
