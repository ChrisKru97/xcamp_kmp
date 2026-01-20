package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

/**
 * Speaker domain model
 *
 * Matches Firestore structure where:
 * - id (String): Firestore document ID - used as uid in database
 * - name (String): Speaker name
 * - description (String?): Optional biographical text
 * - priority (Long): Sorting priority (lower = higher priority)
 * - image (String?): Optional Firebase Storage reference
 *
 * The numeric id for the database is generated from the uid (document ID).
 */
@Serializable
data class Speaker(
    val id: String,  // Firestore document ID - becomes uid in database
    val name: String,
    val description: String? = null,
    val priority: Long,
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
 * Convert Firestore Speaker to database format with generated numeric ID
 */
fun Speaker.toDbSpeaker(): cz.krutsche.xcamp.shared.db.Speaker {
    return cz.krutsche.xcamp.shared.db.Speaker(
        id = Speaker.generateId(this.id),
        uid = this.id,
        name = this.name,
        description = this.description,
        priority = this.priority,
        image = this.image,
        imageUrl = this.imageUrl
    )
}
