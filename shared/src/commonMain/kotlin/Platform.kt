package cz.krutsche.xcamp.shared

expect class Platform {
    val version: String
    val type: PlatformType
    val model: String
    val name: String
    val systemName: String

    val appVersion: String
    val buildNumber: String
    val buildType: String
    val locale: String
    val screenSize: String
}

enum class PlatformType {
    ANDROID, IOS
}