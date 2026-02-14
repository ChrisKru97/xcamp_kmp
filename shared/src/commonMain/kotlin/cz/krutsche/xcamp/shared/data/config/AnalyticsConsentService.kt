package cz.krutsche.xcamp.shared.data.config

import cz.krutsche.xcamp.shared.data.ServiceFactory

expect object AnalyticsConsentService {
    fun hasConsent(): Boolean
    fun grantConsent()
    fun revokeConsent()
}
