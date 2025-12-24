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
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        context.startActivity(intent)
    }
}
