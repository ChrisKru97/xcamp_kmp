package cz.krutsche.xcamp.shared.domain.model

import cz.krutsche.xcamp.shared.data.firebase.StorageService

/**
 * Generic extension to populate image URLs for entities with images
 *
 * This function eliminates code duplication between SpeakersRepository and PlacesRepository
 * by providing a reusable way to fetch and populate image URLs for any entity with
 * an `image` field (String?) and an `imageUrl` field (String?).
 *
 * @param storageService StorageService for fetching download URLs
 * @param entityName Name of entity type for logging (e.g., "speaker", "place")
 * @param copyWithUrl Function to create a new instance of T with the updated imageUrl
 * @return List of entities with populated imageUrl fields
 */
suspend inline fun <reified T : Any> List<T>.populateImageUrls(
    storageService: StorageService,
    entityName: String,
    crossinline copyWithUrl: T.(String?) -> T
): List<T> {
    return map { entity ->
        // Get image path using reflection
        val imageField = when (T::class) {
            Speaker::class -> (entity as? Speaker)?.image
            Place::class -> (entity as? Place)?.image
            else -> null
        }

        if (imageField != null) {
            val urlResult = storageService.getDownloadUrl(imageField)
            entity.copyWithUrl(urlResult.getOrNull())
        } else {
            entity
        }
    }
}
