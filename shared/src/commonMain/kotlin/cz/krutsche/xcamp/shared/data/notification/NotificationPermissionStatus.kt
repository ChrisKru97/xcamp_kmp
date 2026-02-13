package cz.krutsche.xcamp.shared.data.notification

sealed class NotificationPermissionStatus {
    data object Authorized : NotificationPermissionStatus()
    data object Denied : NotificationPermissionStatus()
}
