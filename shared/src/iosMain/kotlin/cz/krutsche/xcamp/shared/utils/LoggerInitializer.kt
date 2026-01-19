package cz.krutsche.xcamp.shared.utils

import io.github.aakira.napier.DebugAntilog
import io.github.aakira.napier.Napier

/**
 * Initializes Napier logging for iOS platform.
 * Should be called early in app startup (e.g., in XcampApp.init())
 *
 * Note: This can be called multiple times safely - Napier will just override
 * the existing antilog with a new one.
 */
fun initializeLogger() {
    Napier.base(DebugAntilog())
}
