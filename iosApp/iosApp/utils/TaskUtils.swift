import Foundation

final class TaskCanceller {
    private var _task: Task<Void, Never>?

    var task: Task<Void, Never>? { _task }

    func cancel() {
        _task?.cancel()
    }

    @MainActor
    func run(_ operation: @escaping () async -> Void) {
        _task?.cancel()
        _task = Task {
            await operation()
        }
    }
}
