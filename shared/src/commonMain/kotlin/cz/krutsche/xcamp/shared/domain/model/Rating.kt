package cz.krutsche.xcamp.shared.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Rating(
    val id: Long,
    val category: String,
    val rating: Int? = null,
    val comment: String? = null,
    val timestamp: Instant
)

@Serializable
enum class RatingCategory {
    HARMONOGRAM_DNE,
    CHROST,
    DUCHOVNI_PORADENSTVI,
    SVOLAVACI_ZNELKA,
    INFOBUDKA,
    VYZDOBA_STANU,
    MERCY_CAFE,
    OSTATNI
}