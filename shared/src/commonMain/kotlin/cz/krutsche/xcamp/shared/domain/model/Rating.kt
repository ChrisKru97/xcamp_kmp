package cz.krutsche.xcamp.shared.domain.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Rating(
    val id: Long,
    val category: String,
    val rating: Int? = null, // 1-5 stars, null if not rated
    val comment: String? = null,
    val timestamp: Instant
)

@Serializable
enum class RatingCategory {
    HARMONOGRAM_DNE, // Harmonogram dne
    CHROST, // Chrost
    DUCHOVNI_PORADENSTVI, // Duchovní poradenství
    SVOLAVACI_ZNELKA, // Svolávací znělka
    INFOBUDKA, // Infobudka
    VYZDOBA_STANU, // Výzdoba stanu a modlitební místnosti
    MERCY_CAFE, // Mercy café
    OSTATNI // Ostatní
}