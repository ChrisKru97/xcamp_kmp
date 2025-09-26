package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.storage.FirebaseStorage
import dev.gitlive.firebase.storage.storage
import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

class StorageService {
    private val storage: FirebaseStorage = Firebase.storage

    suspend fun uploadFile(
        path: String,
        data: ByteArray,
        contentType: String? = null
    ): Result<String> {
        return try {
            withTimeout(30.seconds) {
                // TODO: Fix proper platform-specific ByteArray to Data conversion
                // val storageRef = storage.reference.child(path)
                // storageRef.putData(data.toPlatformData())
                // val downloadUrl = storageRef.getDownloadUrl()
                Result.failure(Exception("Storage upload not yet implemented"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDownloadUrl(path: String): Result<String> {
        return try {
            withTimeout(5.seconds) {
                val storageRef = storage.reference.child(path)
                val downloadUrl = storageRef.getDownloadUrl()
                Result.success(downloadUrl)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteFile(path: String): Result<Unit> {
        return try {
            withTimeout(5.seconds) {
                val storageRef = storage.reference.child(path)
                storageRef.delete()
                Result.success(Unit)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun listFiles(path: String): Result<List<String>> {
        return try {
            withTimeout(10.seconds) {
                val storageRef = storage.reference.child(path)
                val listResult = storageRef.listAll()
                val filePaths = listResult.items.map { it.path }
                Result.success(filePaths)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}