package cz.krutsche.xcamp.shared.data.local

enum class EntityType(val collectionName: String) {
    PLACES("places"),
    SPEAKERS("speakers"),
    SECTIONS("schedule"),
    SONGS("songs"),
    NEWS("news"),
    RATINGS("ratings"), // TODO remove, online - only feature
    USERS("users") // TODO remove, not user oriented
}
