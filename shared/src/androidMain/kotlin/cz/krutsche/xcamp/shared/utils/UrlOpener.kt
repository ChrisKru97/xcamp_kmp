package cz.krutsche.xcamp.shared.utils

import android.content.Context
import android.content.Intent
import android.net.Uri

actual object UrlOpener {
    private lateinit var context: Context

    fun init(context: Context) {
        this.context = context
    }

    actual fun openUrl(url: String) {
        if (!::context.isInitialized) return

        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        if (intent.resolveActivity(context.packageManager) != null) {
            context.startActivity(intent)
        }
    }
}
