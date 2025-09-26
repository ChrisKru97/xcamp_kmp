package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Place(
    val id: Long,
    val uid: String,
    val name: String,
    val description: String? = null,
    val priority: Long,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val image: String? = null,
    val imageUrl: String? = null
)