package cz.krutsche.xcamp.shared.data.network

import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.flow.first
import platform.Network.nw_path_monitor_create
import platform.Network.nw_path_monitor_set_queue
import platform.Network.nw_path_monitor_start
import platform.Network.nw_path_monitor_cancel
import platform.Network.nw_path_monitor_set_update_handler
import platform.Network.nw_path_get_status
import platform.Network.nw_path_status_satisfied
import platform.darwin.dispatch_get_main_queue

actual fun createConnectivityObserver(): ConnectivityObserver {
    return ConnectivityObserverIos()
}

class ConnectivityObserverIos : ConnectivityObserver {

    override val connectivityStatus: Flow<ConnectivityStatus> = callbackFlow {
        val monitor = nw_path_monitor_create()
        val queue = dispatch_get_main_queue()

        // Emit initial status immediately when collector starts
        val initialStatus = when (nw_path_get_status(monitor)) {
            nw_path_status_satisfied -> ConnectivityStatus.ONLINE
            else -> ConnectivityStatus.OFFLINE
        }
        trySend(initialStatus)

        nw_path_monitor_set_update_handler(monitor) {
            val connectivityStatus = when (nw_path_get_status(it)) {
                nw_path_status_satisfied -> ConnectivityStatus.ONLINE
                else -> ConnectivityStatus.OFFLINE
            }
            trySend(connectivityStatus)
        }

        nw_path_monitor_set_queue(monitor, queue)
        nw_path_monitor_start(monitor)

        awaitClose {
            nw_path_monitor_cancel(monitor)
        }
    }.conflate() // Only emit latest status, prevent backpressure

    override suspend fun getCurrentStatus(): ConnectivityStatus {
        return connectivityStatus.first()
    }
}
