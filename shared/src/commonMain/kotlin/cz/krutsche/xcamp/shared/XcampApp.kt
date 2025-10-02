package cz.krutsche.xcamp.shared

import cz.krutsche.xcamp.shared.data.config.AppInitializer

class XcampApp(
    private val appInitializer: AppInitializer
) {
    suspend fun initialize(): Result<Unit> = appInitializer.initialize()
}