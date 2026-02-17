package cz.krutsche.xcamp.shared.domain.model

import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.LocalTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class Section(
    val uid: String,
    val name: String,
    val description: String? = null,
    val days: List<Int>,
    val startTime: String,
    val endTime: String,
    val place: String? = null,
    val speakers: List<String>? = null,
    val leader: String? = null,
    val type: SectionType,
    val favorite: Boolean = false
) {
    companion object {
        private val json = Json { ignoreUnknownKeys = true }

        fun fromFirestoreData(documentId: String, data: FirestoreSection): Section {
            require(documentId.isNotBlank()) { "Section document ID cannot be blank" }
            require(data.name.isNotBlank()) { "Section name cannot be blank" }
            return Section(
                uid = documentId,
                name = data.name,
                description = data.description,
                days = data.days,
                startTime = data.startTime,
                endTime = data.endTime,
                place = data.place,
                speakers = data.speakers?.let { json.decodeFromString<List<String>>(it) },
                leader = data.leader,
                type = SectionType.valueOf(data.type?.uppercase() ?: SectionType.MAIN.name),
                favorite = data.favorite
            )
        }
    }

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

    private fun parseDateTime(year: Int, month: Int, day: Int, time: String): kotlinx.datetime.Instant {
        val parsedTime = LocalTime.parse(time)
        val localDateTime = LocalDateTime(
            year, month, day,
            parsedTime.hour, parsedTime.minute, 0, 0
        )
        return localDateTime.toInstant(TimeZone.UTC)
    }
}

@Serializable
data class ExpandedSection(
    val base: Section,
    val dayIndex: Int,
    val startTime: kotlinx.datetime.Instant,
    val endTime: kotlinx.datetime.Instant
) {
    val uid: String get() = base.uid
    val name: String get() = base.name
    val description: String? get() = base.description
    val day: Int get() = base.days[dayIndex]
    val place: String? get() = base.place
    val speakers: List<String>? get() = base.speakers
    val leader: String? get() = base.leader
    val type: SectionType get() = base.type
    val favorite: Boolean get() = base.favorite
}

@Serializable
enum class SectionType {
    MAIN,
    INTERNAL,
    GOSPEL,
    FOOD
}

@Serializable
data class FirestoreSection(
    val name: String,
    val description: String? = null,
    val days: List<Int>,
    val startTime: String,
    val endTime: String,
    val place: String? = null,
    val speakers: String? = null,
    val leader: String? = null,
    val type: String,
    val favorite: Boolean = false
)