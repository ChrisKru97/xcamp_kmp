package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory
import cz.krutsche.xcamp.shared.data.firebase.AnalyticsHelper

actual object AnalyticsConsentService {
    actual fun hasConsent(): Boolean {
        return AppPreferences.getAnalyticsConsent()
    }

    actual fun grantConsent() {
        AppPreferences.setAnalyticsConsent(true)
        val auth = ServiceFactory.getAuthService()
        auth.currentUserId?.let { userId ->
            AnalyticsHelper.setUserId(userId)
        }
    }

    actual fun revokeConsent() {
        AppPreferences.setAnalyticsConsent(false)
        AnalyticsHelper.setUserId(null)
    }
}
