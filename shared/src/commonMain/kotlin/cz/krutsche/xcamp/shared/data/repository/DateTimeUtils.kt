@file:OptIn(kotlin.time.ExperimentalTime::class)
package cz.krutsche.xcamp.shared.data.repository

import kotlin.time.Clock.System.now
import kotlin.time.ExperimentalTime
import kotlin.time.Instant

fun getCurrentTimeMillis(): Long =
    now().toEpochMilliseconds()
