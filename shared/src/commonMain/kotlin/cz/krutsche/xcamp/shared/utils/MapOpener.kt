package cz.krutsche.xcamp.shared.utils

expect object MapOpener {
    /**
     * Opens a map application at the specified coordinates.
     * Tries available map apps with platform-specific fallbacks.
     */
    fun openMap(latitude: Double, longitude: Double, name: String)
}
