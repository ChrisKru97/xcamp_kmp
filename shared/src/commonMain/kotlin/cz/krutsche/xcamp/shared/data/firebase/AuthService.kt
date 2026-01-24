package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.auth.FirebaseAuth
import dev.gitlive.firebase.auth.auth

class AuthService {
    private val auth: FirebaseAuth = Firebase.auth

    val currentUserId: String?
        get() = auth.currentUser?.uid

    suspend fun initialize(): Result<String> {
        return try {
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
}
