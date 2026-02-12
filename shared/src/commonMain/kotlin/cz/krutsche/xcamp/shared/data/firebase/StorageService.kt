@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.firebase

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.storage.FirebaseStorage
import dev.gitlive.firebase.storage.storage
import kotlinx.coroutines.withTimeout
import kotlin.time.Clock.System.now
import kotlin.time.Duration.Companion.seconds

class StorageService {
    private val storage: FirebaseStorage = Firebase.storage

    private val urlCache = mutableMapOf<String, Pair<String, Long>>()

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

    suspend fun getDownloadUrl(path: String, forceRefresh: Boolean = false): Result<String> {
        val cached = urlCache[path]
        val currentTime = now().toEpochMilliseconds()

        if (!forceRefresh && cached != null && (currentTime - cached.second) < DEFAULT_STALENESS_MS) {
            return Result.success(cached.first)
        }

        return try {
            withTimeout(DEFAULT_TIMEOUT) {
                val storageRef = storage.reference.child(path)
                val downloadUrl = storageRef.getDownloadUrl()
                urlCache[path] = downloadUrl to currentTime
                Result.success(downloadUrl)
            }
        } catch (e: Exception) {
            if (cached != null) {
                Result.success(cached.first)
            } else {
                Result.failure(e)
            }
        }
    }

    suspend fun deleteFile(path: String): Result<Unit> {
        return try {
            withTimeout(DEFAULT_TIMEOUT) {
                val storageRef = storage.reference.child(path)
                storageRef.delete()
                urlCache.remove(path)
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

    fun clearCache() {
        urlCache.clear()
    }
}
