package cz.krutsche.xcamp.shared.util

import kotlinx.coroutines.withTimeout
import kotlin.time.Duration.Companion.seconds

object NetworkUtils {
    private val DEFAULT_TIMEOUT = 5.seconds

    suspend fun <T> withNetworkTimeout(
        timeout: kotlin.time.Duration = DEFAULT_TIMEOUT,
        block: suspend () -> T
    ): Result<T> {
        return try {
            val result = withTimeout(timeout) {
                block()
            }
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}