import Foundation
import shared

enum AppError: LocalizedError {
    case notFound
    case network
    case storage
    case validation
    case cacheEmpty
    case notificationPermission
    case notificationSchedule
    case notificationDisabled
    case unknown

    var errorDescription: String? {
        switch self {
        case .notFound:
            return Strings.Common.shared.ERROR_NOT_FOUND
        case .network:
            return Strings.Common.shared.ERROR_NETWORK
        case .storage:
            return Strings.Common.shared.ERROR_STORAGE
        case .validation:
            return Strings.Common.shared.ERROR_VALIDATION
        case .cacheEmpty:
            return Strings.Common.shared.ERROR_CACHE_EMPTY
        case .notificationPermission:
            return Strings.Common.shared.ERROR_NOTIFICATION_PERMISSION
        case .notificationSchedule:
            return Strings.Common.shared.ERROR_NOTIFICATION_SCHEDULE
        case .notificationDisabled:
            return Strings.Common.shared.ERROR_NOTIFICATION_DISABLED
        case .unknown:
            return Strings.Common.shared.ERROR_UNKNOWN
        }
    }

    var title: String {
        return Strings.Common.shared.ERROR_TITLE
    }

    static func from(_ error: Error) -> AppError {
        // Handle Kotlin AppError types directly
        if error is NotFoundError { return .notFound }
        if error is NetworkError { return .network }
        if error is StorageError { return .storage }
        if error is ValidationError { return .validation }
        if error is CacheEmptyError { return .cacheEmpty }
        if error is NotificationPermissionError { return .notificationPermission }
        if error is NotificationScheduleError { return .notificationSchedule }
        if error is NotificationDisabledError { return .notificationDisabled }

        // Fallback for NSError (404 not found)
        if let nsError = error as? NSError {
            if nsError.code == 404 { return .notFound }
        }
        return .unknown
    }
}
