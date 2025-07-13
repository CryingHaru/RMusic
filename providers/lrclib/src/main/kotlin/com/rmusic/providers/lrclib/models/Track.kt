package com.rmusic.providers.lrclib.models

import com.rmusic.providers.lrclib.LrcParser
import com.rmusic.providers.lrclib.toLrcFile
import kotlinx.serialization.Serializable
import kotlin.math.abs
import kotlin.time.Duration

@Serializable
data class Track(
    val id: Int,
    val trackName: String,
    val artistName: String,
    val duration: Double,
    val plainLyrics: String?,
    val syncedLyrics: String?
) {
    val lrc by lazy { syncedLyrics?.let { LrcParser.parse(it)?.toLrcFile() } }
}

internal fun List<Track>.bestMatchingFor(title: String, duration: Duration) =
    firstOrNull { it.duration.toLong() == duration.inWholeSeconds }
        ?: minByOrNull { abs(it.trackName.length - title.length) }
