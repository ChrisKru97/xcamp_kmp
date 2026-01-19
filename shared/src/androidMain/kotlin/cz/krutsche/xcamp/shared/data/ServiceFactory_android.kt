package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService

actual object ServiceFactory {
    private val _firestoreService: FirestoreService by lazy { FirestoreService() }

    actual fun getFirestoreService(): FirestoreService = _firestoreService
}
