package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.firebase.StorageService

actual object ServiceFactory {
    private val _firestoreService: FirestoreService by lazy { FirestoreService() }
    private val _storageService: StorageService by lazy { StorageService() }

    actual fun getFirestoreService(): FirestoreService = _firestoreService
    actual fun getStorageService(): StorageService = _storageService
}
