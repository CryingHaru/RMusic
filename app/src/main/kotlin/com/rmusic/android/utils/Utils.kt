@file:OptIn(UnstableApi::class)

package com.rmusic.android.utils

import android.content.ContentUris
import android.net.Uri
import android.provider.MediaStore
import android.text.format.DateUtils
import androidx.annotation.OptIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.core.net.toUri
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.util.UnstableApi
import com.rmusic.android.R
import com.rmusic.android.models.Song
import com.rmusic.android.preferences.AppearancePreferences
import com.rmusic.android.service.LOCAL_KEY_PREFIX
import com.rmusic.android.service.isLocal
import com.rmusic.core.ui.utils.SongBundleAccessor
import com.rmusic.providers.intermusic.pages.SongResult as InterSongResult
import com.rmusic.providers.intermusic.pages.SongItem as InterSongItem
import com.rmusic.providers.intermusic.pages.VideoItem as InterVideoItem
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.onEach
import kotlin.time.Duration

val Song.asMediaItem: MediaItem
    get() = MediaItem.Builder()
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(title)
                .setArtist(artistsText)
                .setArtworkUri(thumbnailUrl?.toUri())
                .setExtras(
                    SongBundleAccessor.bundle {
                        durationText = this@asMediaItem.durationText
                        explicit = this@asMediaItem.explicit
                    }
                )
                .build()
        )
        .setMediaId(id)
        .setUri(
            when {
                // Handle downloaded songs with direct file path
                id.startsWith("download:") -> {
                    // Try to get the downloaded song from the database
                    // This will be resolved later in the PlayerService
                    id.toUri()
                }
                isLocal -> ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    id.substringAfter(LOCAL_KEY_PREFIX).toLong()
                )
                else -> id.toUri()
            }
        )
        .setCustomCacheKey(id)
        .build()

// Intermusic provider mappings (prefer this when authenticated)
val InterSongResult.asMediaItem: MediaItem
    get() = MediaItem.Builder()
        .setMediaId(videoId)
        .setUri(videoId)
        .setCustomCacheKey(videoId)
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(title)
                .setArtist(artists.joinToString(separator = ", ") { it.name })
                .setAlbumTitle(album?.title)
                .setArtworkUri(thumbnails.firstOrNull()?.url?.toUri())
                .setExtras(
                    SongBundleAccessor.bundle {
                        albumId = album?.browseId
                        durationText = duration
                        artistNames = artists.map { it.name }
                        artistIds = artists.mapNotNull { it.browseId }
                    }
                )
                .build()
        )
        .build()

val InterSongItem.asMediaItem: MediaItem
    get() = MediaItem.Builder()
        .setMediaId(videoId)
        .setUri(videoId)
        .setCustomCacheKey(videoId)
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(title)
                .setArtist(artists.joinToString(separator = ", ") { it.name })
                .setAlbumTitle(album?.title)
                .setArtworkUri(thumbnails.firstOrNull()?.url?.toUri())
                .setExtras(
                    SongBundleAccessor.bundle {
                        albumId = album?.browseId
                        durationText = duration
                        artistNames = artists.map { it.name }
                        artistIds = artists.mapNotNull { it.browseId }
                    }
                )
                .build()
        )
        .build()

fun InterSongResult.toMediaItem(): MediaItem = asMediaItem

val InterVideoItem.asMediaItem: MediaItem
    get() = MediaItem.Builder()
        .setMediaId(videoId)
        .setUri(videoId)
        .setCustomCacheKey(videoId)
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(title)
                .setArtist(author)
                .setArtworkUri(thumbnails.firstOrNull()?.url?.toUri())
                .setExtras(
                    SongBundleAccessor.bundle {
                        durationText = duration
                        artistNames = listOfNotNull(author)
                    }
                )
                .build()
        )
        .build()

val Duration.formatted
    @Composable get() = toComponents { hours, minutes, _, _ ->
        when {
            hours == 0L -> stringResource(id = R.string.format_minutes, minutes)
            hours < 24L -> stringResource(id = R.string.format_hours, hours)
            else -> stringResource(id = R.string.format_days, hours / 24)
        }
    }

fun String?.thumbnail(
    size: Int,
    maxSize: Int = AppearancePreferences.maxThumbnailSize
): String? {
    val actualSize = size.coerceAtMost(maxSize)
    return when {
        this?.startsWith("file://") == true -> this // Return local file URLs as-is for downloaded content
        this?.startsWith("https://lh3.googleusercontent.com") == true -> "$this-w$actualSize-h$actualSize"
        this?.startsWith("https://yt3.ggpht.com") == true -> "$this-w$actualSize-h$actualSize-s$actualSize"
        this?.startsWith("https://i.ytimg.com/vi/") == true -> {
            // For YouTube video thumbnails, prefer high resolution versions
            when {
                actualSize >= 1280 -> this.replace("/mqdefault.jpg", "/maxresdefault.jpg")
                    .replace("/hqdefault.jpg", "/maxresdefault.jpg")
                    .replace("/sddefault.jpg", "/maxresdefault.jpg")
                actualSize >= 480 -> this.replace("/mqdefault.jpg", "/hqdefault.jpg")
                    .replace("/sddefault.jpg", "/hqdefault.jpg")
                else -> this
            }
        }
        else -> this
    }
}

fun Uri?.thumbnail(size: Int) = toString().thumbnail(size)?.toUri()

fun formatAsDuration(millis: Long) = DateUtils.formatElapsedTime(millis / 1000).removePrefix("0")

fun <T> Flow<T>.onFirst(block: suspend (T) -> Unit): Flow<T> {
    var isFirst = true

    return onEach {
        if (!isFirst) return@onEach

        block(it)
        isFirst = false
    }
}

inline fun <reified T : Throwable> Throwable.findCause(): T? {
    if (this is T) return this

    var th = cause
    while (th != null) {
        if (th is T) return th
        th = th.cause
    }

    return null
}
