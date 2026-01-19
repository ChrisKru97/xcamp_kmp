@file:OptIn(ExperimentalTime::class)

package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import kotlin.time.Clock.System.now
import kotlin.time.Duration.Companion.days
import kotlin.time.ExperimentalTime
import kotlin.time.Instant

const val EventLength = 8

class AppConfigService(
    private val remoteConfigService: RemoteConfigService
) {
    suspend fun initialize(): Result<Unit> {
        return remoteConfigService.initialize()
    }

    private fun parseStartDate(): Instant {
        val startDateStr = remoteConfigService.getStartDate()
        // Remote Config returns date in format "YYYY-MM-DD" but Instant.parse() requires full ISO-8601
        // Append time component if missing
        val fullDateTimeStr = if (startDateStr.length == 10) {
            "${startDateStr}T00:00:00Z"
        } else {
            startDateStr
        }
        return Instant.parse(fullDateTimeStr)
    }

    private fun getEndOfEvent(): Instant {
        val startDate = parseStartDate()
        return startDate + EventLength.days
    }

    private fun isEventActive(): Boolean {
        val startDate = parseStartDate()
        val today = now()
        return today >= startDate && !isEventOver()
    }

    private fun isEventOver(): Boolean {
        val endDate = getEndOfEvent()
        val today = now()
        return today >= endDate
    }

    /**
     * Determines current app state based on event dates and showAppData flag
     */
    fun getAppState(): AppState {
        return when {
            !remoteConfigService.shouldShowAppData() -> AppState.LIMITED
            isEventOver() -> AppState.POST_EVENT
            isEventActive() -> AppState.ACTIVE_EVENT
            else -> AppState.PRE_EVENT
        }
    }

    fun shouldShowCountdown(): Boolean {
        return when (getAppState()) {
            AppState.LIMITED, AppState.PRE_EVENT -> true
            AppState.ACTIVE_EVENT, AppState.POST_EVENT -> false
        }
    }

    /**
     * Get the available bottom navigation tabs based on current app state
     */
    fun getAvailableTabs(): List<AppTab> {
        return when (getAppState()) {
            AppState.LIMITED -> listOf(AppTab.HOME, AppTab.MEDIA, AppTab.INFO)

            AppState.PRE_EVENT, AppState.ACTIVE_EVENT -> listOf(
                AppTab.HOME,
                AppTab.SCHEDULE,
                AppTab.SPEAKERS,
                AppTab.PLACES,
                AppTab.MEDIA,
                AppTab.INFO
            )

            AppState.POST_EVENT -> listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.RATING, AppTab.MEDIA, AppTab.INFO)
        }
    }

    fun getEventYear(): String {
        return remoteConfigService.getStartDate().take(4)
    }
}

enum class AppState {
    LIMITED,      // showAppData = false: Only Home, Media, Info
    PRE_EVENT,    // Before event starts: Full navigation
    ACTIVE_EVENT, // During event: Full navigation
    POST_EVENT    // After event: Home, Schedule, Rating, Media, Info
}

enum class AppTab {
    HOME,
    SCHEDULE,
    SPEAKERS,
    PLACES,
    RATING,
    MEDIA,
    INFO
}