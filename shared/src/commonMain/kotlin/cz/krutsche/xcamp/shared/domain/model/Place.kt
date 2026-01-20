package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

/**
 * Place domain model
 *
 * Matches Firestore structure where:
 * - id (String): Firestore document ID - used as uid in database
 * - name (String): Place name
 * - description (String?): Optional description text
 * - priority (Long): Sorting priority (lower = higher priority)
 * - latitude (Double?): Optional GPS coordinate
 * - longitude (Double?): Optional GPS coordinate
 * - image (String?): Optional Firebase Storage reference
 *
 * The numeric id for the database is generated from the uid (document ID).
 */
@Serializable
data class Place(
    val id: String,  // Firestore document ID - becomes uid in database
    val name: String,
    val description: String? = null,
    val priority: Long,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val image: String? = null,
    val imageUrl: String? = null  // Computed URL for display
) {
    companion object {
        /**
         * Generate a numeric ID from the document ID for database storage
         * Uses a simple hash of the document ID
         */
        fun generateId(uid: String): Long {
            return uid.hashCode().toLong()
        }
    }
}

/**
 * Convert Firestore Place to database format with generated numeric ID
 */
fun Place.toDbPlace(): cz.krutsche.xcamp.shared.db.Place {
    return cz.krutsche.xcamp.shared.db.Place(
        id = Place.generateId(this.id),
        uid = this.id,
        name = this.name,
        description = this.description,
        priority = this.priority,
        latitude = this.latitude,
        longitude = this.longitude,
        image = this.image,
        imageUrl = this.imageUrl
    )
}