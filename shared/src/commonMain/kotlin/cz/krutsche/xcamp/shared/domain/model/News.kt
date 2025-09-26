package cz.krutsche.xcamp.shared.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class News(
    val id: Long,
    val uid: String,
    val title: String,
    val text: String,
    val time: Instant
)