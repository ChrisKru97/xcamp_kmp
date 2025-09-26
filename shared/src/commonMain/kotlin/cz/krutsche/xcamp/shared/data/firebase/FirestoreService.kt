package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.firestore.FirebaseFirestore
import dev.gitlive.firebase.firestore.firestore
import kotlinx.coroutines.withTimeout
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.SerializationStrategy
import kotlin.time.Duration.Companion.seconds

class FirestoreService {
    private val firestore: FirebaseFirestore = Firebase.firestore

    suspend fun <T> getDocument(
        collection: String,
        documentId: String,
        deserializer: DeserializationStrategy<T>
    ): Result<T?> {
        return try {
            withTimeout(5.seconds) {
                val document = firestore.collection(collection).document(documentId).get()
                if (document.exists) {
                    val data = document.data(deserializer)
                    Result.success(data)
                } else {
                    Result.success(null)
                }
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun <T> getCollection(
        collection: String,
        deserializer: DeserializationStrategy<T>
    ): Result<List<T>> {
        return try {
            withTimeout(5.seconds) {
                val querySnapshot = firestore.collection(collection).get()
                val documents = querySnapshot.documents.mapNotNull { document ->
                    if (document.exists) {
                        document.data(deserializer)
                    } else null
                }
                Result.success(documents)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun setDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> {
        return try {
            withTimeout(5.seconds) {
                firestore.collection(collection).document(documentId).set(data)
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun addDocument(
        collection: String,
        data: Any
    ): Result<String> {
        return try {
            withTimeout(5.seconds) {
                val docRef = firestore.collection(collection).add(data)
                Result.success(docRef.id)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteDocument(
        collection: String,
        documentId: String
    ): Result<Unit> {
        return try {
            withTimeout(5.seconds) {
                firestore.collection(collection).document(documentId).delete()
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateDocument(
        collection: String,
        documentId: String,
        data: Any
    ): Result<Unit> {
        return try {
            withTimeout(5.seconds) {
                firestore.collection(collection).document(documentId).update(data)
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}