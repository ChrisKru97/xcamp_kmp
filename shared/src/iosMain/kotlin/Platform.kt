package cz.krutsche.xcamp.shared

import platform.Foundation.NSBundle
import platform.UIKit.UIDevice
import platform.UIKit.UIScreen
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents
import platform.Foundation.NSLocale
import platform.Foundation.currentLocale

actual class Platform {
    actual val version: String
        get() = UIDevice.currentDevice.systemVersion
    actual val type: PlatformType
        get() = PlatformType.IOS
    actual val model: String
        get() = UIDevice.currentDevice.model
    actual val name: String
        get() = UIDevice.currentDevice.name
    actual val systemName: String
        get() = UIDevice.currentDevice.systemName

    @OptIn(ExperimentalForeignApi::class)
    actual val appVersion: String
        get() = (NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String) ?: "1.0.0"

    @OptIn(ExperimentalForeignApi::class)
    actual val buildNumber: String
        get() = (NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleVersion") as? String) ?: "1"

    actual val buildType: String
        get() {
            @OptIn(ExperimentalForeignApi::class)
            val isSimulator = UIDevice.currentDevice.name.contains("Simulator", ignoreCase = true) ||
                             NSBundle.mainBundle.objectForInfoDictionaryKey("DTPlatformName") == "iphonesimulator"
            return if (isSimulator) "debug" else "release"
        }

    @OptIn(ExperimentalForeignApi::class)
    actual val locale: String
        get() = NSLocale.currentLocale.languageCode ?: "en"

    @OptIn(ExperimentalForeignApi::class)
    actual val screenSize: String
        get() = UIScreen.mainScreen.bounds.useContents {
            "${size.width.toInt()} x ${size.height.toInt()}"
        }
}