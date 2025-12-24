package cz.krutsche.xcamp.shared.utils

import platform.Foundation.*
import platform.UIKit.*

actual object UrlOpener {
    actual fun openUrl(url: String) {
        val nsUrl = NSURL.URLWithString(url) ?: return
        UIApplication.sharedApplication.openURL(
            url = nsUrl,
            options = emptyMap<Any?, Any?>(),
            completionHandler = null
        )
    }
}
