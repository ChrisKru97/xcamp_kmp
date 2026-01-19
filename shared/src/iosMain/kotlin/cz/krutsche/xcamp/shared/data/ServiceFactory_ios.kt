package cz.krutsche.xcamp.shared.data

import cz.krutsche.xcamp.shared.data.firebase.FirestoreService

actual object ServiceFactory {
    private val firestoreService: FirestoreService by lazy { FirestoreService() }

    actual fun getFirestoreService(): FirestoreService = firestoreService
}
