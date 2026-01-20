package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService

/**
 * Factory for providing singleton service instances across the app.
 * Ensures that expensive services like FirestoreService are only created once.
 */
expect object ServiceFactory {
    /**
     * Returns a singleton FirestoreService instance.
     * Multiple calls return the same instance to avoid duplicate connections.
     */
    fun getFirestoreService(): FirestoreService

    /**
     * Returns a singleton StorageService instance.
     * Multiple calls return the same instance to avoid duplicate connections.
     */
    fun getStorageService(): StorageService
}
