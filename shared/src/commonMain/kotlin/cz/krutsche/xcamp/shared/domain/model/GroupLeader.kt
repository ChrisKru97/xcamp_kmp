package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class GroupLeader(
    val id: Long,
    val uid: String,
    val name: String,
    val number: Long,
    val portrait: String? = null,
    val portraitUrl: String? = null,
    val congregation: String? = null
)