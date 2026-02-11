package cz.krutsche.xcamp.shared.data.network

import kotlinx.coroutines.flow.Flow

enum class ConnectivityStatus {
    ONLINE,
    OFFLINE
}

interface ConnectivityObserver {
    val connectivityStatus: Flow<ConnectivityStatus>

    suspend fun getCurrentStatus(): ConnectivityStatus
}

expect fun createConnectivityObserver(): ConnectivityObserver
