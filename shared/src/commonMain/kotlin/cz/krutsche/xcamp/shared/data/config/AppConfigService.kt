@file:OptIn(ExperimentalTime::class)

package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import io.github.aakira.napier.Napier
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
        val result = Instant.parse(fullDateTimeStr)
        Napier.d(tag = "AppConfigService") { "parseStartDate() -> $result (from '$startDateStr')" }
        return result
    }

    private fun getEndOfEvent(): Instant {
        val startDate = parseStartDate()
        val result = startDate + EventLength.days
        Napier.d(tag = "AppConfigService") { "getEndOfEvent() -> $result (startDate + $EventLength days)" }
        return result
    }

    private fun isEventActive(): Boolean {
        val startDate = parseStartDate()
        val today = now()
        val result = today >= startDate && !isEventOver()
        Napier.d(tag = "AppConfigService") { "isEventActive(): today=$today, startDate=$startDate, result=$result" }
        return result
    }

    private fun isEventOver(): Boolean {
        val endDate = getEndOfEvent()
        val today = now()
        val result = today >= endDate
        Napier.d(tag = "AppConfigService") { "isEventOver(): today=$today, endDate=$endDate, result=$result" }
        return result
    }

    /**
     * Determines current app state based on event dates and showAppData flag
     */
    fun getAppState(): AppState {
        Napier.i(tag = "AppConfigService") { "getAppState() called - starting evaluation..." }

        val showAppData = remoteConfigService.shouldShowAppData()
        Napier.d(tag = "AppConfigService") { "getAppState() - showAppData = $showAppData" }

        val result = when {
            !showAppData -> {
                Napier.d(tag = "AppConfigService") { "getAppState() -> LIMITED (showAppData is false)" }
                AppState.LIMITED
            }
            isEventOver() -> {
                Napier.d(tag = "AppConfigService") { "getAppState() -> POST_EVENT (event is over)" }
                AppState.POST_EVENT
            }
            isEventActive() -> {
                Napier.d(tag = "AppConfigService") { "getAppState() -> ACTIVE_EVENT (event is active)" }
                AppState.ACTIVE_EVENT
            }
            else -> {
                Napier.d(tag = "AppConfigService") { "getAppState() -> PRE_EVENT (before event, showAppData is true)" }
                AppState.PRE_EVENT
            }
        }

        Napier.i(tag = "AppConfigService") { "getAppState() returning: $result" }
        return result
    }

    fun shouldShowCountdown(): Boolean {
        val state = getAppState()
        val result = state == AppState.LIMITED || state == AppState.PRE_EVENT
        Napier.d(tag = "AppConfigService") { "shouldShowCountdown() -> $result (appState=$state)" }
        return result
    }

    /**
     * Get the available bottom navigation tabs based on current app state
     */
    fun getAvailableTabs(): List<AppTab> {
        val state = getAppState()
        val result = when (state) {
            AppState.LIMITED -> {
                Napier.d(tag = "AppConfigService") { "getAvailableTabs() -> LIMITED tabs: HOME, MEDIA, INFO" }
                listOf(AppTab.HOME, AppTab.MEDIA, AppTab.INFO)
            }

            AppState.PRE_EVENT, AppState.ACTIVE_EVENT -> {
                Napier.d(tag = "AppConfigService") { "getAvailableTabs() -> FULL tabs (state=$state): HOME, SCHEDULE, SPEAKERS, PLACES, MEDIA, INFO" }
                listOf(
                    AppTab.HOME,
                    AppTab.SCHEDULE,
                    AppTab.SPEAKERS,
                    AppTab.PLACES,
                    AppTab.MEDIA,
                    AppTab.INFO
                )
            }

            AppState.POST_EVENT -> {
                Napier.d(tag = "AppConfigService") { "getAvailableTabs() -> POST_EVENT tabs: HOME, SCHEDULE, RATING, MEDIA, INFO" }
                listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.RATING, AppTab.MEDIA, AppTab.INFO)
            }
        }
        Napier.i(tag = "AppConfigService") { "getAvailableTabs() returning ${result.size} tabs" }
        return result
    }

    fun getEventYear(): String {
        val startDate = remoteConfigService.getStartDate()
        val result = startDate.take(4)
        Napier.d(tag = "AppConfigService") { "getEventYear() -> '$result' (from startDate '$startDate')" }
        return result
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