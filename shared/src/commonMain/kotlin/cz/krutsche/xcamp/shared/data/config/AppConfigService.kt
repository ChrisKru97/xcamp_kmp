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

    private fun getEndOfEvent(): Instant {
        val startDateStr = remoteConfigService.getStartDate()
        val startDate = Instant.parse(startDateStr)
        return startDate + EventLength.days
    }

    private fun isEventActive(): Boolean {
        val startDateStr = remoteConfigService.getStartDate()
        val startDate = Instant.parse(startDateStr)
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