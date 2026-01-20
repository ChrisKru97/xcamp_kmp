package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService

actual object ServiceFactory {
    private val firestoreService: FirestoreService by lazy { FirestoreService() }
    private val storageService: StorageService by lazy { StorageService() }

    actual fun getFirestoreService(): FirestoreService = firestoreService
    actual fun getStorageService(): StorageService = storageService
}
