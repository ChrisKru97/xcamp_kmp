package cz.krutsche.xcamp.shared.data.firebase

import cz.krutsche.xcamp.shared.Platform
import cz.krutsche.xcamp.shared.data.DEFAULT_TIMEOUT
import cz.krutsche.xcamp.shared.data.repository.UsersRepository
import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.auth.FirebaseAuth
import dev.gitlive.firebase.auth.auth
import kotlinx.coroutines.withTimeout

class AuthService(
    private val usersRepository: UsersRepository
) {
    private val auth: FirebaseAuth = Firebase.auth

    val currentUserId: String?
        get() = auth.currentUser?.uid

    suspend fun initialize(): Result<String> = withTimeout(DEFAULT_TIMEOUT) {
        try {
            val currentUser = auth.currentUser
            if (currentUser != null) {
                Result.success(currentUser.uid)
            } else {
                val result = auth.signInAnonymously()
                val uid = result.user?.uid
                if (uid != null) {
                    Result.success(uid)
                } else {
                    Result.failure(Exception("Anonymous sign in failed: no user ID"))
                }
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun registerUserWithDevice(
        platform: Platform,
        fcmToken: String?
    ): Result<Unit> = withTimeout(DEFAULT_TIMEOUT) {
        val token = fcmToken
            ?: return@withTimeout Result.failure(Exception("FCM token is null"))
        val userId = currentUserId
            ?: return@withTimeout Result.failure(Exception("User not authenticated"))

        usersRepository.registerUser(
            userId,
            platform,
            token
        )
    }

    suspend fun updateFCMToken(token: String): Result<Unit> = withTimeout(DEFAULT_TIMEOUT) {
        val userId = currentUserId
            ?: return@withTimeout Result.failure(Exception("User not authenticated"))

        usersRepository.updateFCMToken(userId, token)
    }
}
