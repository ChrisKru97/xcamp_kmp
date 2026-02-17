import android.content.res.Resources
import android.os.Build
import android.content.pm.PackageManager
import android.content.pm.ApplicationInfo
import cz.krutsche.xcamp.shared.data.config.AppPreferences

actual class Platform {
    actual val version: String
        get() = Build.VERSION.RELEASE_OR_CODENAME
    actual val type = PlatformType.ANDROID
    actual val model: String
        get() = "${Build.MANUFACTURER} ${Build.MODEL}"
    actual val name: String
        get() = Build.DEVICE

    actual val appVersion: String
        get() {
            return try {
                val packageInfo = AppPreferences.context.packageManager.getPackageInfo(AppPreferences.context.packageName, 0)
                packageInfo.versionName ?: "1.0.0"
            } catch (e: PackageManager.NameNotFoundException) {
                "1.0.0"
            }
        }

    actual val buildNumber: String
        get() {
            return try {
                val packageInfo = AppPreferences.context.packageManager.getPackageInfo(AppPreferences.context.packageName, 0)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    packageInfo.longVersionCode.toString()
                } else {
                    @Suppress("DEPRECATION")
                    packageInfo.versionCode.toString()
                }
            } catch (e: PackageManager.NameNotFoundException) {
                "1"
            }
        }

    actual val buildType: String
        get() {
            return try {
                val packageInfo = AppPreferences.context.packageManager.getPackageInfo(AppPreferences.context.packageName, 0)
                val appInfo = packageInfo.applicationInfo ?: return "release"
                val isDebug = (appInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
                if (isDebug) "debug" else "release"
            } catch (e: PackageManager.NameNotFoundException) {
                "release"
            }
        }

    actual val locale: String
        get() {
            val config = Resources.getSystem().configuration
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                config.locales[0].toLanguageTag()
            } else {
                @Suppress("DEPRECATION")
                config.locale.toString()
            }
        }

    actual val screenSize: String
        get() {
            val metrics = Resources.getSystem().displayMetrics
            return "${metrics.widthPixels} x ${metrics.heightPixels}"
        }

    actual val systemName: String
        get() = "Android ${Build.VERSION.RELEASE}"
}