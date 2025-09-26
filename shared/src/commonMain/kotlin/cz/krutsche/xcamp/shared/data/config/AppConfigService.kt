package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import cz.krutsche.xcamp.shared.data.local.DevConfigService
import kotlinx.datetime.LocalDate

class AppConfigService(
    private val remoteConfigService: RemoteConfigService,
    private val devConfigService: DevConfigService
) {

    suspend fun initialize(): Result<Unit> {
        return remoteConfigService.initialize()
    }

    /**
     * Returns true if app should show full event data (Schedule, Speakers, Places tabs)
     * Returns false for limited mode (Home, Media, Info only)
     */
    fun shouldShowAppData(): Boolean {
        // Dev override takes precedence
        devConfigService.getShowAppDataOverride()?.let { return it }

        // Fall back to remote config
        return remoteConfigService.shouldShowAppData()
    }

    /**
     * Returns the event start date from remote config
     * Default: 2026-07-18
     */
    fun getEventStartDate(): String {
        return remoteConfigService.getStartDate()
    }

    /**
     * Returns the QR reset PIN
     */
    fun getQrResetPin(): String {
        // Dev override takes precedence
        devConfigService.getQrResetPinOverride()?.let { return it }

        // Fall back to remote config
        return remoteConfigService.getQrResetPin()
    }

    /**
     * Determines if event is currently active based on start date
     */
    fun isEventActive(): Boolean {
        return try {
            val eventDate = LocalDate.parse(getEventStartDate())
            val today = kotlinx.datetime.Clock.System.todayIn(kotlinx.datetime.TimeZone.currentSystemDefault())
            val eventEndDate = eventDate.plus(kotlinx.datetime.DatePeriod(days = 7)) // 7 days after start

            today >= eventDate && today <= eventEndDate
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Determines if event has ended (more than 1 week after start date)
     */
    fun isEventOver(): Boolean {
        return try {
            val eventDate = LocalDate.parse(getEventStartDate())
            val today = kotlinx.datetime.Clock.System.todayIn(kotlinx.datetime.TimeZone.currentSystemDefault())
            val eventEndDate = eventDate.plus(kotlinx.datetime.DatePeriod(days = 7)) // 7 days after start

            today > eventEndDate
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Determines current app state based on event dates and showAppData flag
     */
    fun getAppState(): AppState {
        return when {
            !shouldShowAppData() -> AppState.LIMITED
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
            AppState.PRE_EVENT -> listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.SPEAKERS, AppTab.PLACES, AppTab.MEDIA, AppTab.INFO)
            AppState.ACTIVE_EVENT -> listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.SPEAKERS, AppTab.PLACES, AppTab.MEDIA, AppTab.INFO)
            AppState.POST_EVENT -> listOf(AppTab.HOME, AppTab.SCHEDULE, AppTab.RATING, AppTab.MEDIA, AppTab.INFO)
        }
    }

    suspend fun refresh(): Result<Unit> {
        return remoteConfigService.refresh()
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