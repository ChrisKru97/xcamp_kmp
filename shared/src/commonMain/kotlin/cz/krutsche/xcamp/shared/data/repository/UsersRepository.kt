@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import Platform
import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.firebase.Analytics
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsEvents
import cz.krutsche.xcamp.shared.data.firebase.CrashlyticsService
import cz.krutsche.xcamp.shared.data.firebase.FirestoreService
import cz.krutsche.xcamp.shared.data.local.EntityType
import kotlinx.serialization.Serializable
import kotlin.time.Clock.System.now

@Serializable
data class UserInfo(
    val id: String,
    val token: String,
    val type: String,
    val model: String,
    val version: String,
    val appVersion: String,
    val buildNumber: String,
    val locale: String,
    val screenSize: String,
    val createdAt: Long
) {
    companion object {
        fun fromPlatform(
            id: String,
            token: String,
            platform: Platform,
            createdAt: Long = now().toEpochMilliseconds()
        ): UserInfo = UserInfo(
            id = id,
            token = token,
            type = platform.type.name,
            model = platform.model,
            version = platform.version,
            appVersion = platform.appVersion,
            buildNumber = platform.buildNumber,
            locale = platform.locale,
            screenSize = platform.screenSize,
            createdAt = createdAt
        )
    }
}

class UsersRepository(
    private val firestoreService: FirestoreService
) {
    private val collectionName: String = EntityType.USERS.collectionName

    suspend fun registerUser(
        userId: String,
        platform: Platform,
        fcmToken: String
    ): Result<Unit> {
        val startTime = now().toEpochMilliseconds()
        val userInfo = UserInfo.fromPlatform(userId, fcmToken, platform)
        val result = firestoreService.setDocument(collectionName, userId, userInfo)

        var success = false
        result.fold(
            onSuccess = { success = true },
            onFailure = {
                CrashlyticsService.logNonFatalError(it)
                CrashlyticsService.setCustomKey("registration_phase", "firebase_firestore")
                CrashlyticsService.setCustomKey("user_id", userId)
                success = false
            }
        )

        val durationMs = now().toEpochMilliseconds() - startTime
        logUserAction(actionType = "register", success = success, durationMs = durationMs)

        return result
    }

    suspend fun updateFCMToken(
        userId: String,
        token: String
    ): Result<Unit> {
        val startTime = now().toEpochMilliseconds()
        val result = firestoreService.updateDocument(
            collectionName,
            userId,
            mapOf("token" to token)
        )

        var success = false
        result.fold(
            onSuccess = { success = true },
            onFailure = {
                CrashlyticsService.logNonFatalError(it)
                CrashlyticsService.setCustomKey("registration_phase", "fcm_token_update")
                CrashlyticsService.setCustomKey("user_id", userId)
                success = false
            }
        )

        val durationMs = now().toEpochMilliseconds() - startTime
        logUserAction(actionType = "fcm_token_update", success = success, durationMs = durationMs)

        return result
    }

    private fun logUserAction(actionType: String, success: Boolean, durationMs: Long) {
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
