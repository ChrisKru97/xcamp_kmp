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
    let appError: AppError
    let retry: (() async -> Void)?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text(appError.title)
                .font(.headline)
            Text(appError.errorDescription ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button(Strings.Common.shared.RETRY) {
                    Task { await retry() }
                }
                .glassButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    init(error: Error, retry: (() async -> Void)? = nil) {
        self.appError = AppError.from(error)
        self.retry = retry
    }

    init(appError: AppError, retry: (() async -> Void)? = nil) {
        self.appError = appError
        self.retry = retry
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

// MARK: - Card Components

struct CardLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
    }
}

// MARK: - View Modifiers

extension View {
    func switchingContent<T>(
        _ state: ContentState<T>,
        @ViewBuilder loading: () -> some View = { LoadingView() },
        @ViewBuilder content: @escaping (T, Bool) -> some View,
        @ViewBuilder error: @escaping (Error) -> some View
    ) -> some View {
        Group {
            switch state {
            case .loading:
                loading()
            case .loaded(let data, let isStale):
                content(data, isStale)
            case .refreshing(let data):
                content(data, false)
            case .error(let err):
                error(err)
            }
        }
    }
}
