package cz.krutsche.xcamp.shared.data.config

import kotlinx.serialization.Serializable

@Serializable
enum class ScheduleNotificationMode {
    OFF,
    FAVORITES,
    ALL
}

@Serializable
data class NotificationPreferences(
    val newsEnabled: Boolean = true,
    val scheduleMode: ScheduleNotificationMode = ScheduleNotificationMode.FAVORITES,
    val prayerDayEnabled: Boolean = true
)
