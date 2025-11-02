package com.rmusic.android.preferences

import com.rmusic.android.models.Song
import com.rmusic.providers.innertube.Innertube
import kotlinx.serialization.Serializable

@Serializable
data class CachedSongSummary(
    val id: String,
    val title: String,
    val artistsText: String? = null,
    val durationText: String? = null,
    val thumbnailUrl: String? = null,
    val explicit: Boolean = false
)

@Serializable
data class QuickPicksSnapshot(
    val trending: CachedSongSummary? = null,
    val related: Innertube.RelatedPage? = null,
    val timestamp: Long = 0L
)

fun QuickPicksSnapshot.hasContent(): Boolean =
    trending != null || related.hasContent()

fun Innertube.RelatedPage?.hasContent(): Boolean =
    this?.let {
        !it.songs.isNullOrEmpty() ||
            !it.artists.isNullOrEmpty() ||
            !it.albums.isNullOrEmpty() ||
            !it.playlists.isNullOrEmpty()
    } ?: false

fun Song.toSnapshot(): CachedSongSummary = CachedSongSummary(
    id = id,
    title = title,
    artistsText = artistsText,
    durationText = durationText,
    thumbnailUrl = thumbnailUrl,
    explicit = explicit
)

fun CachedSongSummary.toSong(): Song = Song(
    id = id,
    title = title,
    artistsText = artistsText,
    durationText = durationText,
    thumbnailUrl = thumbnailUrl,
    explicit = explicit
)
