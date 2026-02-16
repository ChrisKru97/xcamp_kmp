package cz.krutsche.xcamp.shared.data.firebase

object AnalyticsEvents {
    const val SCREEN_VIEW = "screen_view"
    const val PARAM_SCREEN_NAME = "screen_name"
    const val PARAM_TAB_NAME = "tab_name"

    // Tab switching
    const val TAB_SWITCH = "tab_switch"
    const val PARAM_PREVIOUS_TAB = "previous_tab"

    // Day selection
    const val DAY_SELECT = "day_select"
    const val PARAM_DAY_NUMBER = "day_number"
    const val PARAM_DAY_NAME = "day_name"

    // Favorites
    const val FAVORITE_ADD = "favorite_add"
    const val FAVORITE_REMOVE = "favorite_remove"
    const val PARAM_ENTITY_TYPE = "entity_type"
    const val PARAM_ENTITY_ID = "entity_id"
    const val PARAM_ENTITY_NAME = "entity_name"

    // Content viewing
    const val CONTENT_VIEW = "content_view"
    const val PARAM_CONTENT_TYPE = "content_type"
    const val PARAM_CONTENT_ID = "content_id"

    // Filtering
    const val FILTER_TOGGLE = "filter_toggle"
    const val FILTER_FAVORITES = "filter_favorites"
    const val PARAM_FILTER_TYPE = "filter_type"
    const val PARAM_ENABLED = "enabled"

    // Refresh
    const val PULL_REFRESH = "pull_refresh"

    // Notifications
    const val NOTIFICATION_PREF_CHANGE = "notification_pref_change"
    const val NOTIFICATION_REQUEST = "notification_request"
    const val PARAM_PREF_TYPE = "pref_type"
    const val PARAM_GRANTED = "granted"

    // Media
    const val MEDIA_LINK_CLICK = "media_link_click"
    const val PARAM_LINK_TYPE = "link_type"
    const val PARAM_URL = "url"

    // Map
    const val MAP_VIEW = "map_view"
    const val PARAM_VIEW_TYPE = "view_type"

    // Content state
    const val CONTENT_STATE = "content_state"
    const val PARAM_STATE = "state"

    // Data operations
    const val DATA_SYNC = "data_sync"
    const val CACHE_HIT = "cache_hit"
    const val PARAM_DURATION_MS = "duration_ms"
    const val PARAM_HIT = "hit"

    // User actions
    const val USER_ACTION = "user_action"
    const val PARAM_ACTION_TYPE = "action_type"
    const val SUCCESS = "success"

    // Error tracking
    const val PARAM_ERROR_TYPE = "error_type"
}
