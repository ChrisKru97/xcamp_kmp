@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.notification

import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.config.AppPreferences
import cz.krutsche.xcamp.shared.data.config.DEFAULT_START_DATE
import cz.krutsche.xcamp.shared.data.config.NotificationPreferences
import cz.krutsche.xcamp.shared.data.config.ScheduleNotificationMode
import cz.krutsche.xcamp.shared.data.firebase.Analytics
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsEvents
import cz.krutsche.xcamp.shared.data.repository.ScheduleRepository
import cz.krutsche.xcamp.shared.data.repository.NotificationPermissionError
import cz.krutsche.xcamp.shared.domain.model.Section
import cz.krutsche.xcamp.shared.localization.Strings
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.messaging.messaging
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeout
import platform.Foundation.NSDate
import platform.Foundation.NSDateComponents
import platform.Foundation.NSCalendar
import platform.Foundation.timeIntervalSince1970
import platform.UserNotifications.*
import platform.Foundation.NSCalendarUnitYear
import platform.Foundation.NSCalendarUnitMonth
import platform.Foundation.NSCalendarUnitDay
import platform.Foundation.NSCalendarUnitHour
import platform.Foundation.NSCalendarUnitMinute
import platform.Foundation.NSCalendarUnitSecond
import kotlin.coroutines.resume
import kotlin.time.Clock.System.now

private const val NOTIFICATION_IDENTIFIER_PREFIX = "schedule_notification_"
private const val PRAYER_NOTIFICATION_IDENTIFIER_PREFIX = "prayer_notification_"
private const val NOTIFICATION_ADVANCE_MINUTES = 15L
private const val PRAYER_NOTIFICATION_HOUR = 8L

actual class NotificationService {

    private var _currentPreferences: NotificationPreferences? = null
    private var fcmToken: String? = null

    private val _scheduleRepository: ScheduleRepository by lazy {
        ServiceFactory.getScheduleRepository()
    }

    private val notificationCenter get() = UNUserNotificationCenter.currentNotificationCenter()

    actual fun getPreferences(): NotificationPreferences {
        return _currentPreferences ?: AppPreferences.getNotificationPreferences().also {
            _currentPreferences = it
        }
    }

    actual suspend fun initialize() {
        _currentPreferences = AppPreferences.getNotificationPreferences()
        if (hasPermission()) {
            retrieveFCMToken()
        }
    }

    actual suspend fun getPermissionStatus(): NotificationPermissionStatus = suspendCancellableCoroutine { continuation ->
        notificationCenter.getNotificationSettingsWithCompletionHandler { settings ->
            val status = when (settings?.authorizationStatus) {
                UNAuthorizationStatusAuthorized -> NotificationPermissionStatus.Authorized
                else -> NotificationPermissionStatus.Denied
            }
            continuation.resume(status)
        }
    }

    actual suspend fun requestPermission(): Result<NotificationPermissionStatus> = suspendCancellableCoroutine { continuation ->
        notificationCenter.getNotificationSettingsWithCompletionHandler { settings ->
            when (settings?.authorizationStatus) {
                UNAuthorizationStatusNotDetermined -> {
                    val options = UNAuthorizationOptionAlert.toInt() or
                                  UNAuthorizationOptionSound.toInt() or
                                  UNAuthorizationOptionBadge.toInt()

                    notificationCenter.requestAuthorizationWithOptions(options = options.toULong()) { granted, error ->
                        if (error != null) {
                            continuation.resume(Result.failure(NotificationPermissionError))
                        } else {
                            val status = if (granted) NotificationPermissionStatus.Authorized
                                         else NotificationPermissionStatus.Denied
                            Analytics.logEvent(
                                name = AnalyticsEvents.NOTIFICATION_REQUEST,
                                parameters = mapOf(AnalyticsEvents.PARAM_GRANTED to granted.toString())
                            )
                            continuation.resume(Result.success(status))
                        }
                    }
                }
                UNAuthorizationStatusAuthorized -> {
                    Analytics.logEvent(
                        name = AnalyticsEvents.NOTIFICATION_REQUEST,
                        parameters = mapOf(AnalyticsEvents.PARAM_GRANTED to "true")
                    )
                    continuation.resume(Result.success(NotificationPermissionStatus.Authorized))
                }
                else -> {
                    continuation.resume(Result.failure(NotificationPermissionError))
                }
            }
        }
    }

    actual suspend fun hasPermission(): Boolean {
        return getPermissionStatus() is NotificationPermissionStatus.Authorized
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
        val notificationTime = startTimeMillis - (NOTIFICATION_ADVANCE_MINUTES * 60 * 1000)
        val currentTime = now().toEpochMilliseconds()

        if (notificationTime <= currentTime) {
            return
        }

        val identifier = "$NOTIFICATION_IDENTIFIER_PREFIX${section.uid}_$dayIndex"

        val content = UNMutableNotificationContent()
        content.setTitle(section.name)
        content.setBody(Strings.Notifications.NOTIFICATION_IN_MINUTES)

        val date = NSDate(notificationTime / 1000.0)
        val calendar = NSCalendar.currentCalendar
        val components = calendar.components(
            NSCalendarUnitYear or
            NSCalendarUnitMonth or
            NSCalendarUnitDay or
            NSCalendarUnitHour or
            NSCalendarUnitMinute or
            NSCalendarUnitSecond,
            date
        )

        val trigger = UNCalendarNotificationTrigger.triggerWithDateMatchingComponents(
            dateComponents = components,
            repeats = false
        )

        val request = UNNotificationRequest.requestWithIdentifier(
            identifier = identifier,
            content = content,
            trigger = trigger
        )

        notificationCenter.addNotificationRequest(request) { error ->
            if (error != null) {
                println("Failed to schedule notification: ${error.localizedDescription}")
            }
        }
    }

    actual suspend fun cancelAllScheduleNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    actual suspend fun refreshScheduleNotifications() {
        cancelAllScheduleNotifications()

        val mode = getPreferences().scheduleMode
        if (mode == ScheduleNotificationMode.OFF) {
            return
        }

        val sections = _scheduleRepository.getAllSections()
        val sectionsToNotify = when (mode) {
            ScheduleNotificationMode.OFF -> emptyList()
            ScheduleNotificationMode.FAVORITES -> sections.filter { it.favorite }
            ScheduleNotificationMode.ALL -> sections
        }

        sectionsToNotify.forEach { section ->
            val startDate = DEFAULT_START_DATE
            val expandedSections = section.expand(startDate)
            expandedSections.forEachIndexed { dayIndex, expandedSection ->
                scheduleSectionNotification(
                    section = section,
                    dayIndex = dayIndex,
                    startTimeMillis = expandedSection.startTime.epochSeconds * 1000
                )
            }
        }
    }

    actual suspend fun getFCMToken(): String? = fcmToken

    actual fun updatePreferences(preferences: NotificationPreferences) {
        _currentPreferences = preferences
        AppPreferences.setNotificationPreferences(preferences)
    }

    actual suspend fun schedulePrayerNotifications(startDate: String) {
        val dateParts = startDate.split("-")
        if (dateParts.size != 3) return

        val eventYear = dateParts[0].toIntOrNull() ?: return
        val eventMonth = dateParts[1].toIntOrNull() ?: return
        val dayOfMonth = dateParts[2].toIntOrNull() ?: return

        val content = UNMutableNotificationContent().apply {
            setTitle(Strings.Notifications.PRAYER_NOTIFICATION_TITLE)
        }

        for (month in 1 until eventMonth) {
            val identifier = "${PRAYER_NOTIFICATION_IDENTIFIER_PREFIX}${eventYear}_${month}"

            val calendar = NSCalendar.currentCalendar
            val components = NSDateComponents().apply {
                year = eventYear.toLong()
                this.month = month.toLong()
                day = dayOfMonth.toLong()
                hour = PRAYER_NOTIFICATION_HOUR
                minute = 0L
            }

            val trigger = UNCalendarNotificationTrigger.triggerWithDateMatchingComponents(
                dateComponents = components,
                repeats = false
            )

            val request = UNNotificationRequest.requestWithIdentifier(
                identifier = identifier,
                content = content,
                trigger = trigger
            )

            notificationCenter.addNotificationRequest(request) { error ->
                if (error != null) {
                    println("Failed to schedule prayer notification for $eventYear-$month: ${error.localizedDescription}")
                }
            }
        }
    }

    actual suspend fun cancelPrayerNotification() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
