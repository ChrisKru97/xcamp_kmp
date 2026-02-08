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

    actual val appVersion: String
    actual val buildNumber: String
    actual val buildType: String
    actual val locale: String
    actual val screenSize: String

    init {
        val bundle = NSBundle.mainBundle
        appVersion = (bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String) ?: "unknown"
        buildNumber = (bundle.objectForInfoDictionaryKey("CFBundleVersion") as? String) ?: "0"

        val isSimulator = UIDevice.currentDevice.name.contains("Simulator", ignoreCase = true)
        buildType = if (isSimulator) "debug" else "release"
        locale = NSLocale.currentLocale.localeIdentifier
        screenSize = run {
            val bounds = UIScreen.mainScreen.bounds
            bounds.useContents {
                "${size.width.toInt()} x ${size.height.toInt()}"
            }
        }
    }
}