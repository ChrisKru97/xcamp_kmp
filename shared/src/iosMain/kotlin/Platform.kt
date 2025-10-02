import platform.UIKit.UIDevice

actual class Platform {
    actual val version: String = UIDevice.currentDevice.systemVersion()
    actual val type: PlatformType = PlatformType.IOS
    actual val model: String = UIDevice.currentDevice.model()
    actual val name: String = UIDevice.currentDevice.name()
}