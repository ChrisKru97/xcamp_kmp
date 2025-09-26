package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Song(
    val number: Long,
    val name: String,
    val text: String
)