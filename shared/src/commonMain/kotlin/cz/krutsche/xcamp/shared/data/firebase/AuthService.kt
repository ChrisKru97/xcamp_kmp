package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.auth.FirebaseAuth
import dev.gitlive.firebase.auth.auth
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class AuthService {
    private val auth: FirebaseAuth = Firebase.auth

    val currentUserId: String?
        get() = auth.currentUser?.uid

    val isAuthenticated: Flow<Boolean> = auth.authStateChanged.map { user ->
        user != null
    }

    suspend fun signInAnonymously(): Result<String> {
        return try {
            val result = auth.signInAnonymously()
            val uid = result.user?.uid
            if (uid != null) {
                Result.success(uid)
            } else {
                Result.failure(Exception("Anonymous sign in failed: no user ID"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun signOut(): Result<Unit> {
        return try {
            auth.signOut()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

}