package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.firebase.RemoteConfigService
import kotlinx.datetime.DateTimePeriod
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.atStartOfDayIn
import kotlinx.datetime.plus
import kotlin.time.Clock.System.now

const val EventLength = 8
const val DEFAULT_START_DATE = "2026-07-18"

class AppConfigService(
    private val remoteConfigService: RemoteConfigService
) {

    suspend fun initialize(): Result<Unit> {
        return remoteConfigService.initialize()
    }

    private fun parseStartDate(): Instant {
        val startDateStr = remoteConfigService.startDate
        val parsedDate = LocalDate.parse(startDateStr)
        return parsedDate.atStartOfDayIn(TimeZone.UTC)
    }

    private fun getEndOfEvent(): Instant {
        val startDate = parseStartDate()
        return startDate.plus(DateTimePeriod(days = EventLength), TimeZone.UTC)
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

    fun getAppState(): AppState = AppPreferences.getAppStateOverride() ?: getAppStateComputed()

    fun getAppStateOverride(): AppState? = AppPreferences.getAppStateOverride()

    private fun getAppStateComputed(): AppState {
        val showAppData = remoteConfigService.showAppData

        return when {
            !showAppData -> AppState.LIMITED
            isEventOver() -> AppState.POST_EVENT
            isEventActive() -> AppState.ACTIVE_EVENT
            else -> AppState.PRE_EVENT
        }
    }

    fun setAppStateOverride(state: AppState?) {
        AppPreferences.setAppStateOverride(state)
    }

    fun shouldShowCountdown(): Boolean {
        val state = getAppState()
        return state == AppState.LIMITED || state == AppState.PRE_EVENT
    }

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
        val startDate = remoteConfigService.startDate
        return startDate.take(4)
    }

    fun getEventDays(): List<Int> {
        val startDay = remoteConfigService.startDate.split("-")[2].toInt()
        return List(EventLength) { startDay + it }
    }
}

enum class AppState {
    LIMITED,
    PRE_EVENT,
    ACTIVE_EVENT,
    POST_EVENT
}

enum class AppTab {
    HOME,
    SCHEDULE,
    SPEAKERS_AND_PLACES,
    RATING,
    MEDIA,
    ABOUT_FESTIVAL
}
