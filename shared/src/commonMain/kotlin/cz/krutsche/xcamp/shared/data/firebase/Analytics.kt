package cz.krutsche.xcamp.shared.data.firebase

import dev.gitlive.firebase.Firebase
import dev.gitlive.firebase.analytics.analytics
import dev.gitlive.firebase.analytics.FirebaseAnalytics

object Analytics {
    private val analytics = Firebase.analytics

    fun logEvent(name: String, parameters: Map<String, String?> = emptyMap()) {
        val filteredParams = parameters.filterValues { it != null } as Map<String, String>
        analytics.logEvent(name, filteredParams)
    }

    fun logScreenView(screenName: String) {
        analytics.logEvent(
            AnalyticsEvents.SCREEN_VIEW,
            mapOf(AnalyticsEvents.PARAM_SCREEN_NAME to screenName)
        )
    }

    fun setUserId(userId: String?) {
        analytics.setUserId(userId)
    }

    fun setUserProperty(name: String, value: String?) {
        if (value != null) {
            analytics.setUserProperty(name, value)
        }
    }

    fun resetAnalyticsData() {
        analytics.resetAnalyticsData()
    }

    fun setAnalyticsCollectionEnabled(enabled: Boolean) {
        analytics.setAnalyticsCollectionEnabled(enabled)
    }

    fun setConsent(
        analyticsStorage: ConsentStatus = ConsentStatus.GRANTED,
        adStorage: ConsentStatus = ConsentStatus.DENIED,
        adPersonalization: ConsentStatus = ConsentStatus.DENIED,
        adUserData: ConsentStatus = ConsentStatus.DENIED
    ) {
        analytics.setConsent(
            mapOf(
                FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE to analyticsStorage.toGitLive(),
                FirebaseAnalytics.ConsentType.AD_STORAGE to adStorage.toGitLive(),
                FirebaseAnalytics.ConsentType.AD_PERSONALIZATION to adPersonalization.toGitLive(),
                FirebaseAnalytics.ConsentType.AD_USER_DATA to adUserData.toGitLive()
            )
        )
    }

    enum class ConsentStatus {
        GRANTED, DENIED;

        fun toGitLive() = when (this) {
            GRANTED -> FirebaseAnalytics.ConsentStatus.GRANTED
            DENIED -> FirebaseAnalytics.ConsentStatus.DENIED
        }
    }
}
