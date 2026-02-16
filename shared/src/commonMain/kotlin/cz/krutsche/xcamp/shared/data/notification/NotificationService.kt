package cz.krutsche.xcamp.shared.data.notification

import cz.krutsche.xcamp.shared.data.config.NotificationPreferences
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.Section

expect class NotificationService {

    fun getPreferences(): NotificationPreferences

    fun updatePreferences(preferences: NotificationPreferences)

    suspend fun initialize()

    suspend fun cancelAllScheduleNotifications()

    suspend fun refreshScheduleNotifications()

    suspend fun getFCMToken(): String?

    suspend fun schedulePrayerNotifications(startDate: String)

    suspend fun cancelPrayerNotification()

    suspend fun getPermissionStatus(): NotificationPermissionStatus

    suspend fun requestPermission(): Result<NotificationPermissionStatus>

    suspend fun hasPermission(): Boolean
}
