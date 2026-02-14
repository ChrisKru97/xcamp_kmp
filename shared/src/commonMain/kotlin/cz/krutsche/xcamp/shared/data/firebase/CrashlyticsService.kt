package cz.krutsche.xcamp.shared.data.firebase

expect object CrashlyticsService {
    fun setUserId(userId: String)
    fun setCustomKey(key: String, value: String)
    fun logNonFatalError(throwable: Throwable)
    fun log(message: String)
}
