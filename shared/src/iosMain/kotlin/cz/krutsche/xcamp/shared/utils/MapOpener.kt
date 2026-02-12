package cz.krutsche.xcamp.shared.utils

import platform.Foundation.*
import platform.UIKit.*

actual object MapOpener {
    actual fun openMap(latitude: Double, longitude: Double, name: String) {
        val encodedName = (name as NSString).stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLQueryAllowedCharacterSet
        ) ?: ""

        // Try Apple Maps (native, always available)
        if (tryOpenUrl("http://maps.apple.com/?daddr=$latitude,$longitude&q=$encodedName")) {
            return
        }

        // Try Google Maps app
        if (tryOpenUrl("comgooglemaps://?q=$latitude,$longitude")) {
            return
        }

        // Try Waze
        if (tryOpenUrl("waze://?ll=$latitude,$longitude&navigate=yes")) {
            return
        }

        // Fallback to Google Maps web
        tryOpenUrl("https://maps.google.com/?q=$latitude,$longitude")
    }

    private fun tryOpenUrl(urlString: String): Boolean {
        val url = NSURL.URLWithString(urlString) ?: return false
        if (!UIApplication.sharedApplication.canOpenURL(url)) return false
        UIApplication.sharedApplication.openURL(
            url = url,
            options = emptyMap<Any?, Any>(),
            completionHandler = null
        )
        return true
    }
}
