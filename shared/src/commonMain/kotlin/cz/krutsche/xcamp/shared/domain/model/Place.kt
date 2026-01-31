package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

/**
 * Place domain model
 *
 * Matches Firestore structure where:
 * - uid (String): Firestore document ID - used as primary key
 * - name (String): Place name
 * - description (String?): Optional description text
 * - priority (Long): Sorting priority (lower = higher priority)
 * - latitude (Double?): Optional GPS coordinate
 * - longitude (Double?): Optional GPS coordinate
 * - image (String?): Optional Firebase Storage reference
 */
@Serializable
data class Place(
    val uid: String,
    val name: String,
    val description: String? = null,
    val priority: Long,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val image: String? = null,
    val imageUrl: String? = null
) {
    companion object {
        fun fromFirestoreData(documentId: String, data: FirestorePlace): Place {
            require(documentId.isNotBlank()) { "Place document ID cannot be blank" }
            require(data.name.isNotBlank()) { "Place name cannot be blank" }
            return Place(
                uid = documentId,
                name = data.name,
                description = data.description,
                priority = data.priority,
                latitude = data.latitude,
                longitude = data.longitude,
                image = data.image,
                imageUrl = null
            )
        }
    }
}

@Serializable
data class FirestorePlace(
    val name: String,
    val description: String? = null,
    val priority: Long,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val image: String? = null
)

fun Place.toDbPlace(): cz.krutsche.xcamp.shared.db.Place {
    return cz.krutsche.xcamp.shared.db.Place(
        uid = this.uid,
        name = this.name,
        description = this.description,
        priority = this.priority,
        latitude = this.latitude,
        longitude = this.longitude,
        image = this.image,
        imageUrl = this.imageUrl
    )
}