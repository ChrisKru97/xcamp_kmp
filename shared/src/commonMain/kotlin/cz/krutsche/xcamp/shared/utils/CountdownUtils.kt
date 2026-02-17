package cz.krutsche.xcamp.shared.utils

import cz.krutsche.xcamp.shared.localization.Strings

fun getDaysPluralization(days: Int): String {
    return when (days) {
        1 -> Strings.Countdown.DAY
        in 2..4 -> Strings.Countdown.DAYS_FEW
        else -> Strings.Countdown.DAYS
    }
}
