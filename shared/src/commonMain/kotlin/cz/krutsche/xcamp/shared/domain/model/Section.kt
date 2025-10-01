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
    val startTime: Instant,
    val endTime: Instant,
    val place: Long? = null,
    val speakers: List<Long>? = null,
    val leader: String? = null,
    val type: SectionType,
    val favorite: Boolean = false,
    val repeatedDates: List<String>? = null
)

@Serializable
enum class SectionType {
    MAIN,
    INTERNAL,
    GOSPEL,
    FOOD,
    BASIC // Deprecated, same as MAIN
}