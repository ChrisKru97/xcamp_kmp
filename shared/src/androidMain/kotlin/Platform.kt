import android.content.res.Resources
import android.os.Build

actual class Platform {
    actual val version = Build.VERSION.BASE_OS
    actual val type = PlatformType.ANDROID
    actual val model = Build.MANUFACTURER + " " + Build.MODEL
    actual val name = Build.DEVICE

    // TODO finish these values
    actual val appVersion: String
        get() = "1.6.0"
    actual val buildNumber: String
        get() = "60"
    actual val buildType: String
        get() = "release"
    actual val locale: String
        get() = Resources.getSystem().configuration.locales[0].language
    actual val screenSize: String
        get() {
            val metrics = Resources.getSystem().displayMetrics
            return "${metrics.widthPixels} x ${metrics.heightPixels}"
        }
    actual val systemName: String
        get() = "Android"
}