package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Speaker(
    val id: Long,
    val uid: String,
    val name: String,
    val description: String? = null,
    val priority: Long,
    val image: String? = null,
    val imageUrl: String? = null
)