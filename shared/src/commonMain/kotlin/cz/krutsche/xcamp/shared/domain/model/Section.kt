@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.domain.model

import kotlin.time.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Section(
    val id: Long,
    val uid: String,
    val name: String,
    val description: String? = null,
    val days: List<Int>,
    val startTime: String,
    val endTime: String,
    val place: Long? = null,
    val speakers: List<Long>? = null,
    val leader: String? = null,
    val type: SectionType,
    val favorite: Boolean = false
) {
    fun expand(startDate: String): List<ExpandedSection> {
        val (baseYear, baseMonth, _) = startDate.split("-").map { it.toInt() }
        return days.mapIndexed { index, day ->
            val dayStartTime = parseDateTime(baseYear, baseMonth, day, startTime)
            val dayEndTime = parseDateTime(baseYear, baseMonth, day, endTime)
            ExpandedSection(
                base = this,
                dayIndex = index,
                startTime = dayStartTime,
                endTime = dayEndTime
            )
        }
    }

    private fun parseDateTime(year: Int, month: Int, day: Int, time: String): Instant {
        val (hour, minute) = time.split(":").map { it.toInt() }
        val daysInMonth = listOf(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
        val isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        val febDays = if (isLeapYear) 29 else 28

        var totalDays = (year - 1970) * 365
        totalDays += (year - 1969) / 4 - (year - 1901) / 100 + (year - 1601) / 400

        for (m in 1 until month) {
            totalDays += if (m == 2) febDays else daysInMonth[m]
        }
        totalDays += day - 1

        val seconds = totalDays * 86400L + hour * 3600L + minute * 60L
        return Instant.fromEpochSeconds(seconds)
    }
}

@Serializable
data class ExpandedSection(
    val base: Section,
    val dayIndex: Int,
    val startTime: Instant,
    val endTime: Instant
) {
    val id: Long get() = base.id
    val uid: String get() = base.uid
    val name: String get() = base.name
    val description: String? get() = base.description
    val day: Int get() = base.days[dayIndex]
    val place: Long? get() = base.place
    val speakers: List<Long>? get() = base.speakers
    val leader: String? get() = base.leader
    val type: SectionType get() = base.type
    val favorite: Boolean get() = base.favorite
}

@Serializable
enum class SectionType {
    MAIN,
    INTERNAL,
    GOSPEL,
    FOOD,
    BASIC
}