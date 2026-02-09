@file:OptIn(ExperimentalTime::class)

package cz.krutsche.xcamp.shared.utils

import kotlin.time.Clock.System.now
import kotlin.time.ExperimentalTime
import kotlin.time.Instant
import cz.krutsche.xcamp.shared.localization.Strings

// TODO get rid of or simplify and move to androidApp
class CountdownCalculator private constructor(
    private val targetInstant: Instant
) {
    companion object {
        private var INSTANCE: CountdownCalculator? = null

        fun getInstance(dateString: String): CountdownCalculator {
            INSTANCE?.let { return it }

            val targetInstant = Instant.parse("${dateString}T00:00:00Z")
            val instance = CountdownCalculator(targetInstant)
            INSTANCE = instance
            return instance
        }
    }

    fun getTimeRemaining(): String {
        val currentTime = now()
        val totalDiffSeconds = (targetInstant - currentTime).inWholeSeconds

        if (totalDiffSeconds <= 0) {
            return "00:00:00"
        }

        val days = (totalDiffSeconds / 86400).toInt()
        val hours = ((totalDiffSeconds % 86400) / 3600).toInt()
        val minutes = ((totalDiffSeconds % 3600) / 60).toInt()
        val seconds = (totalDiffSeconds % 60).toInt()

        val timeString = "${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${
            seconds.toString().padStart(2, '0')
        }"

        return if (days > 0) {
            "$days ${getDaysPluralization(days)}, $timeString"
        } else {
            timeString
        }
    }

    private fun getDaysPluralization(days: Int): String {
        return when (days) {
            1 -> Strings.Countdown.DAY
            in 2..4 -> Strings.Countdown.DAYS_FEW
            else -> Strings.Countdown.DAYS
        }
    }
}

object CountdownUtils {
    fun createCountdownCalculator(dateString: String): CountdownCalculator {
        return CountdownCalculator.getInstance(dateString)
    }
}

fun getDaysPluralization(days: Int): String {
    return when (days) {
        1 -> Strings.Countdown.DAY
        in 2..4 -> Strings.Countdown.DAYS_FEW
        else -> Strings.Countdown.DAYS
    }
}