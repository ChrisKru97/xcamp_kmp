package cz.krutsche.xcamp.shared.data.repository

sealed class AppError : Exception()

object NotFoundError : AppError()
object NetworkError : AppError()
object StorageError : AppError()
object ValidationError : AppError()
object CacheEmptyError : AppError()
object NotificationPermissionError : AppError()
object NotificationScheduleError : AppError()
object NotificationDisabledError : AppError()
object UnknownError : AppError()
