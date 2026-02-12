package cz.krutsche.xcamp.shared.data.notification

import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.config.NotificationPreferences
import cz.krutsche.xcamp.shared.domain.model.Section
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.messaging.messaging
import kotlinx.coroutines.withTimeout

actual class NotificationService {

    private var _currentPreferences: NotificationPreferences? = null
    private var fcmToken: String? = null

    actual fun getPreferences(): NotificationPreferences {
        return _currentPreferences ?: AppPreferences.getNotificationPreferences().also {
            _currentPreferences = it
        }
    }

    actual suspend fun initialize() {
        _currentPreferences = AppPreferences.getNotificationPreferences()
        retrieveFCMToken()
    }

    private suspend fun retrieveFCMToken() = withTimeout(DEFAULT_TIMEOUT) {
        try {
            val messagingInstance = dev.gitlive.firebase.Firebase.messaging
            val token = messagingInstance.getToken()
            if (!token.isNullOrEmpty()) {
                fcmToken = token
            }
        } catch (e: Exception) {
            println("Failed to retrieve FCM token: ${e.message}")
        }
    }

    private suspend fun scheduleSectionNotification(
        section: Section,
        dayIndex: Int,
        startTimeMillis: Long
    ) {
    }

    actual suspend fun cancelAllScheduleNotifications() {
    }

    actual suspend fun refreshScheduleNotifications() {
    }

    actual suspend fun getFCMToken(): String? = fcmToken

    fun updatePreferences(preferences: NotificationPreferences) {
        _currentPreferences = preferences
        AppPreferences.setNotificationPreferences(preferences)
    }

    actual suspend fun schedulePrayerNotifications(startDate: String) {
    }

    actual suspend fun cancelPrayerNotification() {
    }
}
