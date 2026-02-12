package cz.krutsche.xcamp.shared.utils

import android.content.Context
import android.content.Intent
import android.net.Uri
import java.net.URLEncoder

actual object MapOpener {
    private lateinit var context: Context

    fun init(context: Context) {
        this.context = context
    }

    actual fun openMap(latitude: Double, longitude: Double, name: String) {
        if (!::context.isInitialized) return

        val encodedName = URLEncoder.encode(name, "UTF-8")
        val geoUri = "geo:$latitude,$longitude?q=$latitude,$longitude($encodedName)"
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(geoUri)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        if (intent.resolveActivity(context.packageManager) != null) {
            context.startActivity(intent)
        } else {
            val webUri = Uri.parse("https://maps.google.com/?q=$latitude,$longitude")
            val webIntent = Intent(Intent.ACTION_VIEW, webUri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            if (webIntent.resolveActivity(context.packageManager) != null) {
                context.startActivity(webIntent)
            }
        }
    }
}
