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
        val showAppData = remoteConfigService.shouldShowAppData()

        return when {
            !showAppData -> AppState.LIMITED
            isEventOver() -> AppState.POST_EVENT
            isEventActive() -> AppState.ACTIVE_EVENT
            else -> AppState.PRE_EVENT
        }
    }

    fun shouldShowCountdown(): Boolean {
        val state = getAppState()
        return state == AppState.LIMITED || state == AppState.PRE_EVENT
    }

    /**
     * Get the available bottom navigation tabs based on current app state
     */
    fun getAvailableTabs(): List<AppTab> {
        val state = getAppState()
        return when (state) {
            AppState.LIMITED -> listOf(AppTab.HOME, AppTab.MEDIA, AppTab.ABOUT_FESTIVAL)
            AppState.PRE_EVENT, AppState.ACTIVE_EVENT -> listOf(
                AppTab.HOME,
                AppTab.SCHEDULE,
                AppTab.SPEAKERS_AND_PLACES,
                AppTab.MEDIA,
                AppTab.ABOUT_FESTIVAL
            )
            AppState.POST_EVENT -> listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.RATING, AppTab.MEDIA, AppTab.ABOUT_FESTIVAL)
        }
    }

    fun getEventYear(): String {
        val startDate = remoteConfigService.getStartDate()
        return startDate.take(4)
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
    SPEAKERS_AND_PLACES,
    RATING,
    MEDIA,
    ABOUT_FESTIVAL
}
