package cz.krutsche.xcamp.shared.data.network

import android.Manifest
import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.flow.flowOf

private lateinit var connectivityContext: Context

fun initConnectivityObserver(context: Context) {
    connectivityContext = context
}

class ConnectivityObserverAndroid(
    private val context: Context
) : ConnectivityObserver {
    override val connectivityStatus: Flow<ConnectivityStatus> = flowOf(ConnectivityStatus.ONLINE)

    override suspend fun getCurrentStatus(): ConnectivityStatus {
        return ConnectivityStatus.ONLINE
    }
}

actual fun createConnectivityObserver(): ConnectivityObserver {
    return ConnectivityObserverAndroid(
        context = connectivityContext
    )
}
