package cz.krutsche.xcamp.shared.data.firebase

import cz.krutsche.xcamp.shared.util.NetworkUtils
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.firestore.FirebaseFirestore
import dev.gitlive.firebase.firestore.firestore
import kotlinx.serialization.DeserializationStrategy

class FirestoreService {
    private val firestore: FirebaseFirestore = Firebase.firestore

    suspend fun <T> getDocument(
        collection: String,
        documentId: String,
        deserializer: DeserializationStrategy<T>
    ): Result<T?> = NetworkUtils.withNetworkTimeout {
        val document = firestore.collection(collection).document(documentId).get()
        if (document.exists) document.data(deserializer) else null
    }

    suspend fun <T> getCollection(
        collection: String,
        deserializer: DeserializationStrategy<T>
    ): Result<List<T>> = NetworkUtils.withNetworkTimeout {
        val querySnapshot = firestore.collection(collection).get()
        querySnapshot.documents.mapNotNull { document ->
            if (document.exists) document.data(deserializer) else null
        }
    }

    suspend fun setDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> = NetworkUtils.withNetworkTimeout {
        firestore.collection(collection).document(documentId).set(data)
    }

    suspend fun addDocument(
        collection: String,
        data: Any
    ): Result<String> = NetworkUtils.withNetworkTimeout {
        firestore.collection(collection).add(data).id
    }

    suspend fun deleteDocument(
        collection: String,
        documentId: String
    ): Result<Unit> = NetworkUtils.withNetworkTimeout {
        firestore.collection(collection).document(documentId).delete()
    }

    suspend fun updateDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> = NetworkUtils.withNetworkTimeout {
        firestore.collection(collection).document(documentId).update(data)
    }
}