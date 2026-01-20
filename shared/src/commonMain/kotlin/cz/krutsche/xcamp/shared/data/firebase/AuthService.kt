package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.auth.FirebaseAuth
import dev.gitlive.firebase.auth.auth
import io.github.aakira.napier.Napier

class AuthService {
    private val auth: FirebaseAuth = Firebase.auth

    val currentUserId: String?
        get() = auth.currentUser?.uid

    suspend fun initialize(): Result<String> {
        Napier.d(tag = "AuthService") { "initialize() - Starting anonymous authentication" }
        return try {
            val currentUser = auth.currentUser
            if (currentUser != null) {
                Napier.i(tag = "AuthService") { "initialize() - User already signed in, uid: ${currentUser.uid}" }
                Result.success(currentUser.uid)
            } else {
                Napier.d(tag = "AuthService") { "initialize() - No current user, signing in anonymously..." }
                val result = auth.signInAnonymously()
                val uid = result.user?.uid
                if (uid != null) {
                    Napier.i(tag = "AuthService") { "initialize() - Anonymous sign in successful, uid: $uid" }
                    Napier.d(tag = "AuthService") { "initialize() - User isAnonymous: ${result.user?.isAnonymous ?: "unknown"}" }
                    Napier.d(tag = "AuthService") { "initialize() - User isEmailVerified: ${result.user?.isEmailVerified ?: "unknown"}" }
                    Result.success(uid)
                } else {
                    Napier.e(tag = "AuthService") { "initialize() - Anonymous sign in failed: no user ID returned" }
                    Result.failure(Exception("Anonymous sign in failed: no user ID"))
                }
            }
        } catch (e: Exception) {
            Napier.e(tag = "AuthService", throwable = e) { "initialize() - Anonymous sign in failed with exception: ${e.message}" }
            Result.failure(e)
        }
    }
}