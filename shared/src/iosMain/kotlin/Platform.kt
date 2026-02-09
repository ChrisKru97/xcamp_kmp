import platform.Foundation.NSBundle
import platform.UIKit.UIDevice
import platform.UIKit.UIScreen
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents

actual class Platform {
    actual val version: String = UIDevice.currentDevice.systemVersion
    actual val type: PlatformType = PlatformType.IOS
    actual val model: String = UIDevice.currentDevice.model
    actual val name: String = UIDevice.currentDevice.name
    actual val systemName: String = UIDevice.currentDevice.systemName

    @OptIn(ExperimentalForeignApi::class)
    actual val appVersion: String = (NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String) ?: "1.0.0"

    @OptIn(ExperimentalForeignApi::class)
    actual val buildNumber: String = (NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleVersion") as? String) ?: "1"

    actual val buildType: String = if (UIDevice.currentDevice.name.contains("Simulator", ignoreCase = true)) "debug" else "release"

    // TODO: Implement proper locale retrieval
    actual val locale: String = "en_US"

    @OptIn(ExperimentalForeignApi::class)
    actual val screenSize: String = UIScreen.mainScreen.bounds.useContents {
        "${size.width.toInt()} x ${size.height.toInt()}"
    }
}