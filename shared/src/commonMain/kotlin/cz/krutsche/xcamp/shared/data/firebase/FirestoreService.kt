package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.firestore.FirebaseFirestore
import dev.gitlive.firebase.firestore.firestore
import kotlinx.coroutines.withTimeout
import kotlinx.serialization.DeserializationStrategy
import kotlin.time.Duration.Companion.seconds

class FirestoreService {
    private val firestore: FirebaseFirestore = Firebase.firestore
    private val DEFAULT_TIMEOUT = 5.seconds

    suspend fun <T> getDocument(
        collection: String,
        documentId: String,
        deserializer: DeserializationStrategy<T>
    ): Result<T?> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            val document = firestore.collection(collection).document(documentId).get()
            if (document.exists) document.data(deserializer) else null
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun <T> getCollection(
        collection: String,
        deserializer: DeserializationStrategy<T>
    ): Result<List<T>> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            val querySnapshot = firestore.collection(collection).get()
            querySnapshot.documents.mapNotNull { document ->
                if (document.exists) document.data(deserializer) else null
            }
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun setDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            firestore.collection(collection).document(documentId).set(data)
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun addDocument(
        collection: String,
        data: Any
    ): Result<String> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            firestore.collection(collection).add(data).id
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun deleteDocument(
        collection: String,
        documentId: String
    ): Result<Unit> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            firestore.collection(collection).document(documentId).delete()
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }

    suspend fun updateDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> = try {
        val result = withTimeout(DEFAULT_TIMEOUT) {
            firestore.collection(collection).document(documentId).update(data)
        }
        Result.success(result)
    } catch (e: Exception) {
        Result.failure(e)
    }
}