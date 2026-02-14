package cz.krutsche.xcamp.shared.data.notification

import android.Manifest.permission.POST_NOTIFICATIONS
import cz.krutsche.xcamp.shared.data.ServiceFactory
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.config.NotificationPreferences
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.domain.model.Section
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.messaging.messaging
import kotlinx.coroutines.withTimeout

actual class NotificationService {

    private var _currentPreferences: NotificationPreferences? = null
    private var fcmToken: String? = null

    private val _scheduleRepository: ScheduleRepository by lazy {
        ServiceFactory.getScheduleRepository()
    }

    actual fun getPreferences(): NotificationPreferences {
        return _currentPreferences ?: AppPreferences.getNotificationPreferences().also {
            _currentPreferences = it
        }
    }

    actual suspend fun initialize() {
        _currentPreferences = AppPreferences.getNotificationPreferences()
        retrieveFCMToken()
    }

    actual suspend fun getPermissionStatus(): NotificationPermissionStatus {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
                when {
                    hasPermission() -> NotificationPermissionStatus.Authorized
                    else -> NotificationPermissionStatus.Denied
                }
            }
            else -> NotificationPermissionStatus.Authorized
        }
    }

    actual suspend fun requestPermission(): Result<NotificationPermissionStatus> {
        return Result.success(getPermissionStatus())
    }

    actual suspend fun hasPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val context = AppPreferences.context
            return ContextCompat.checkSelfPermission(
                context,
                POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        }
        return true
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

    actual fun updatePreferences(preferences: NotificationPreferences) {
        _currentPreferences = preferences
        AppPreferences.setNotificationPreferences(preferences)
    }

    actual suspend fun schedulePrayerNotifications(startDate: String) {
    }

    actual suspend fun cancelPrayerNotification() {
    }
}
