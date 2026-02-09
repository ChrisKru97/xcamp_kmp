package cz.krutsche.xcamp.shared.utils

fun needsForceUpdate(currentVersion: String, requiredVersion: String): Boolean {
    val current = currentVersion.split(".").mapNotNull { it.toIntOrNull() }
    val required = requiredVersion.split(".").mapNotNull { it.toIntOrNull() }

    val currentPadded = current + List(3 - current.size) { 0 }
    val requiredPadded = required + List(3 - required.size) { 0 }

    for (i in 0 until 3) {
        if (currentPadded[i] < requiredPadded[i]) return true
        if (currentPadded[i] > requiredPadded[i]) return false
    }
    return false
}
