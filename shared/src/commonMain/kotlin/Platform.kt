expect class Platform {
    val version: String
    val type: PlatformType
    val model: String
    val name: String
}

enum class PlatformType {
    ANDROID, IOS
}