import android.os.Build

actual class Platform {
    actual val version = Build.VERSION.BASE_OS
    actual val type = PlatformType.ANDROID
    actual val model = Build.MANUFACTURER + " " + Build.MODEL
    actual val name = Build.DEVICE
}