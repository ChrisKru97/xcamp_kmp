@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.firebase

import cz.krutsche.xcamp.shared.data.DEFAULT_STALENESS_MS
import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.firebase.Analytics
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsEvents
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService
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
        val startTime = now().toEpochMilliseconds()
        var success = false
        val result: Result<String> = try {
            withTimeout(30.seconds) {
                Result.failure<String>(Exception("Storage upload not yet implemented"))
            }
        } catch (e: Exception) {
            CrashlyticsService.logNonFatalError(e)
            CrashlyticsService.setCustomKey("upload_type", "file")
            CrashlyticsService.setCustomKey("upload_path", path)
            CrashlyticsService.setCustomKey("file_size_bytes", data.size.toString())
            Result.failure(e)
        }

        result.fold(
            onSuccess = { success = true },
            onFailure = { success = false }
        )

        val durationMs = now().toEpochMilliseconds() - startTime
        logStorageAction(actionType = "file_upload", success = success, durationMs = durationMs)

        return result
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
        val startTime = now().toEpochMilliseconds()
        var success = false
        val result: Result<Unit> = try {
            withTimeout(DEFAULT_TIMEOUT) {
                val storageRef = storage.reference.child(path)
                storageRef.delete()
                urlCache.remove(path)
                Result.success(Unit)
            }
        } catch (e: Exception) {
            CrashlyticsService.logNonFatalError(e)
            CrashlyticsService.setCustomKey("storage_operation", "delete")
            CrashlyticsService.setCustomKey("storage_path", path)
            Result.failure(e)
        }

        result.fold(
            onSuccess = { success = true },
            onFailure = { success = false }
        )

        val durationMs = now().toEpochMilliseconds() - startTime
        logStorageAction(actionType = "file_delete", success = success, durationMs = durationMs)

        return result
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
            CrashlyticsService.logNonFatalError(e)
            CrashlyticsService.setCustomKey("storage_operation", "list")
            CrashlyticsService.setCustomKey("storage_path", path)
            Result.failure(e)
        }
    }

    fun clearCache() {
        urlCache.clear()
    }

    private fun logStorageAction(actionType: String, success: Boolean, durationMs: Long) {
        Analytics.logEvent(
            name = AnalyticsEvents.USER_ACTION,
            parameters = mapOf(
                AnalyticsEvents.PARAM_ACTION_TYPE to actionType,
                AnalyticsEvents.SUCCESS to success.toString(),
                AnalyticsEvents.PARAM_DURATION_MS to durationMs.toString()
            )
        )
    }
}
