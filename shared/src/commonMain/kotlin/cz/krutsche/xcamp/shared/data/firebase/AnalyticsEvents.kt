package cz.krutsche.xcamp.shared.data.firebase

object AnalyticsEvents {
    const val SCREEN_VIEW = "screen_view"
    const val PARAM_SCREEN_NAME = "screen_name"
    const val PARAM_TAB_NAME = "tab_name"
    const val PARAM_ITEM_TYPE = "item_type"

    const val FAVORITE_ADD = "favorite_add"
    const val FAVORITE_REMOVE = "favorite_remove"
    const val PARAM_ENTITY_TYPE = "entity_type"
    const val PARAM_ENTITY_ID = "entity_id"
    const val PARAM_ENTITY_NAME = "entity_name"

    const val CONTENT_VIEW = "content_view"
    const val PARAM_CONTENT_TYPE = "content_type"
    const val PARAM_CONTENT_ID = "content_id"

    const val SEARCH = "search"
    const val PARAM_QUERY = "query"
    const val PARAM_CATEGORY = "category"
    const val PARAM_RESULT_COUNT = "result_count"

    const val QR_SCAN = "qr_scan"
    const val PARAM_CONTEXT = "context"

    const val NOTIFICATION_RECEIVE = "notification_receive"
    const val NOTIFICATION_OPEN = "notification_open"
    const val PARAM_TYPE = "type"
    const val PARAM_TOPIC = "topic"

    const val SHARE = "share"
    const val PARAM_METHOD = "method"

    const val MEDIA_UPLOAD = "media_upload"
    const val PARAM_SUCCESS = "success"
    const val PARAM_FILE_TYPE = "file_type"
}
