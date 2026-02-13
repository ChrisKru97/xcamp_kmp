package cz.krutsche.xcamp.shared.data.firebase

import com.google.firebase.crashlytics.ktx.crashlytics
import com.google.firebase.ktx.Firebase

actual object CrashlyticsService {
    private val crashlytics = Firebase.crashlytics

    actual fun setUserId(userId: String) {
        crashlytics.setUserId(userId)
    }

    actual fun setCustomKey(key: String, value: String) {
        crashlytics.setCustomKey(key, value)
    }

    actual fun logNonFatalError(throwable: Throwable) {
        crashlytics.recordException(throwable)
    }

    actual fun log(message: String) {
        crashlytics.log(message)
    }
}
