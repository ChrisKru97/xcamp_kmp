package cz.krutsche.xcamp.shared.data.firebase

import crashlytics.bridge.*
import platform.Foundation.NSLog
import kotlinx.cinterop.ExperimentalForeignApi

@OptIn(ExperimentalForeignApi::class)
actual object CrashlyticsService {

    private val bridge by lazy { CrashlyticsBridge.shared() }

    actual fun setUserId(userId: String) {
        bridge?.setUserId(userId)
    }

    actual fun setCustomKey(key: String, value: String) {
        bridge?.setCustomKey(key, value = value)
    }

    actual fun logNonFatalError(throwable: Throwable) {
        val message = "Non-fatal error: ${throwable.message}\n${throwable.stackTraceToString()}"
        bridge?.recordException(message)
    }

    actual fun log(message: String) {
        bridge?.log(message)
    }
}
