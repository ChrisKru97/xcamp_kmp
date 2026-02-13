@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import Platform
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
        val userInfo = UserInfo.fromPlatform(userId, fcmToken, platform)
        return firestoreService.setDocument(collectionName, userId, userInfo)
    }

    suspend fun updateFCMToken(
        userId: String,
        token: String
    ): Result<Unit> {
        return firestoreService.updateDocument(
            collectionName,
            userId,
            mapOf("token" to token)
        )
    }
}
