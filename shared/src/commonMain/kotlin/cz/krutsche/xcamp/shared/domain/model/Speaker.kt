package cz.krutsche.xcamp.shared.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Speaker(
    val uid: String,
    val name: String,
    val description: String? = null,
    val priority: Long,
    val image: String? = null
) {
    companion object {
        fun fromFirestoreData(documentId: String, data: FirestoreSpeaker): Speaker {
            require(documentId.isNotBlank()) { "Speaker document ID cannot be blank" }
            require(data.name.isNotBlank()) { "Speaker name cannot be blank" }
            return Speaker(
                uid = documentId,
                name = data.name,
                description = data.description,
                priority = data.priority,
                image = data.image
            )
        }
    }
}

@Serializable
data class FirestoreSpeaker(
    val name: String,
    val description: String? = null,
    val priority: Long,
    val image: String? = null
)

fun Speaker.toDbSpeaker(): cz.krutsche.xcamp.shared.db.Speaker {
    return cz.krutsche.xcamp.shared.db.Speaker(
        uid = this.uid,
        name = this.name,
        description = this.description,
        priority = this.priority,
        image = this.image,
        imageUrl = null
    )
}
