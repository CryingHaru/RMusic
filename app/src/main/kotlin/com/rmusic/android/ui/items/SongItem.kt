package com.rmusic.android.ui.items

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.media3.common.MediaItem
import coil3.compose.AsyncImage
import com.rmusic.android.Database
import com.rmusic.android.R
import com.rmusic.android.models.Song
import com.rmusic.android.preferences.AppearancePreferences
import com.rmusic.android.ui.components.themed.TextPlaceholder
import com.rmusic.android.utils.medium
import com.rmusic.android.utils.secondary
import com.rmusic.android.utils.semiBold
import com.rmusic.android.utils.thumbnail
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.shimmer
import com.rmusic.core.ui.utils.px
import com.rmusic.core.ui.utils.songBundle
import com.rmusic.providers.intermusic.pages.SongItem as InterSongItem

@Composable
fun SongItem(
    song: InterSongItem,
    thumbnailSize: Dp,
    modifier: Modifier = Modifier,
    showDuration: Boolean = true,
    clip: Boolean = true,
    isPlaying: Boolean = false,
    hideExplicit: Boolean = AppearancePreferences.hideExplicit
) {
    val thumbnailSizePx = thumbnailSize.px
    val fallbackDisplay = remember(song, thumbnailSize) {
        SongItemDisplay(
            thumbnailUrl = song.thumbnails.maxByOrNull { it.width ?: 0 }?.url?.thumbnail(thumbnailSizePx),
            title = song.title,
            authors = song.artists.joinToString(", ") { it.name },
            duration = song.duration,
            explicit = song.explicit
        )
    }
    val resolvedDisplay = rememberSongItemDisplay(
        songId = song.videoId,
        thumbnailSize = thumbnailSize,
        fallback = fallbackDisplay
    )
    SongItem(
        modifier = modifier,
        thumbnailUrl = resolvedDisplay.thumbnailUrl,
        title = resolvedDisplay.title,
        authors = resolvedDisplay.authors,
        duration = resolvedDisplay.duration,
        explicit = resolvedDisplay.explicit,
        thumbnailSize = thumbnailSize,
        showDuration = showDuration,
        clip = clip,
        isPlaying = isPlaying,
        hideExplicit = hideExplicit
    )
}

@Composable
fun SongItem(
    song: MediaItem,
    thumbnailSize: Dp,
    modifier: Modifier = Modifier,
    onThumbnailContent: (@Composable BoxScope.() -> Unit)? = null,
    trailingContent: (@Composable () -> Unit)? = null,
    showDuration: Boolean = true,
    clip: Boolean = true,
    isPlaying: Boolean = false,
    hideExplicit: Boolean = AppearancePreferences.hideExplicit
) {
    val thumbnailSizePx = thumbnailSize.px
    val extras = remember(song) { song.mediaMetadata.extras?.songBundle }
    val fallbackDisplay = remember(song, thumbnailSize, extras) {
        SongItemDisplay(
            thumbnailUrl = song.mediaMetadata.artworkUri.thumbnail(thumbnailSizePx)?.toString(),
            title = song.mediaMetadata.title?.toString(),
            authors = song.mediaMetadata.artist?.toString(),
            duration = extras?.durationText,
            explicit = extras?.explicit == true
        )
    }
    val resolvedDisplay = rememberSongItemDisplay(
        songId = song.mediaId,
        thumbnailSize = thumbnailSize,
        fallback = fallbackDisplay
    )

    SongItem(
        modifier = modifier,
        thumbnailUrl = resolvedDisplay.thumbnailUrl,
        title = resolvedDisplay.title,
        authors = resolvedDisplay.authors,
        duration = resolvedDisplay.duration,
        explicit = resolvedDisplay.explicit,
        thumbnailSize = thumbnailSize,
        onThumbnailContent = onThumbnailContent,
        trailingContent = trailingContent,
        showDuration = showDuration,
        clip = clip,
        isPlaying = isPlaying,
        hideExplicit = hideExplicit
    )
}

@Composable
fun SongItem(
    song: Song,
    thumbnailSize: Dp,
    modifier: Modifier = Modifier,
    index: Int? = null,
    onThumbnailContent: @Composable (BoxScope.() -> Unit)? = null,
    trailingContent: @Composable (() -> Unit)? = null,
    showDuration: Boolean = true,
    clip: Boolean = true,
    isPlaying: Boolean = false,
    hideExplicit: Boolean = AppearancePreferences.hideExplicit
) = SongItem(
    modifier = modifier,
    index = index,
    thumbnailUrl = song.thumbnailUrl?.thumbnail(thumbnailSize.px),
    title = song.title,
    authors = song.artistsText,
    duration = song.durationText,
    explicit = song.explicit,
    thumbnailSize = thumbnailSize,
    onThumbnailContent = onThumbnailContent,
    trailingContent = trailingContent,
    showDuration = showDuration,
    clip = clip,
    isPlaying = isPlaying,
    hideExplicit = hideExplicit
)

@Composable
private fun SongItem(
    thumbnailUrl: String?,
    title: String?,
    authors: String?,
    duration: String?,
    explicit: Boolean,
    thumbnailSize: Dp,
    modifier: Modifier = Modifier,
    index: Int? = null,
    onThumbnailContent: @Composable (BoxScope.() -> Unit)? = null,
    trailingContent: @Composable (() -> Unit)? = null,
    showDuration: Boolean = true,
    clip: Boolean = true,
    isPlaying: Boolean = false,
    hideExplicit: Boolean = AppearancePreferences.hideExplicit
) {
    val (colorPalette, typography, _, thumbnailShape) = LocalAppearance.current

    SongItem(
        title = title,
        authors = authors,
        duration = duration,
        explicit = explicit,
        thumbnailSize = thumbnailSize,
        thumbnailContent = {
            Box(
                modifier = Modifier
                    .clip(thumbnailShape)
                    .background(colorPalette.background1)
                    .fillMaxSize()
            ) {
                if (thumbnailUrl != null) {
                    AsyncImage(
                        model = thumbnailUrl,
                        error = painterResource(id = R.drawable.ic_launcher_foreground),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                }

                if (index != null) {
                    Box(
                        modifier = Modifier
                            .background(color = Color.Black.copy(alpha = 0.75f))
                            .fillMaxSize()
                    )
                    BasicText(
                        text = "${index + 1}",
                        style = typography.xs.semiBold.copy(color = Color.White),
                        modifier = Modifier.align(Alignment.Center)
                    )
                }

                onThumbnailContent?.invoke(this)
            }
        },
        modifier = modifier,
        trailingContent = trailingContent,
        showDuration = showDuration,
        clip = clip,
        isPlaying = isPlaying,
        hideExplicit = hideExplicit
    )
}

@Composable
private fun SongItem(
    title: String?,
    authors: String?,
    duration: String?,
    explicit: Boolean,
    thumbnailSize: Dp,
    thumbnailContent: @Composable BoxScope.() -> Unit,
    modifier: Modifier = Modifier,
    trailingContent: @Composable (() -> Unit)? = null,
    showDuration: Boolean = true,
    clip: Boolean = true,
    isPlaying: Boolean = false,
    hideExplicit: Boolean = AppearancePreferences.hideExplicit
) {
    val (colorPalette, typography) = LocalAppearance.current

    val backgroundColor by animateColorAsState(
        targetValue = if (isPlaying) colorPalette.background2 else Color.Transparent,
        label = ""
    )

    if (!(hideExplicit && explicit)) ItemContainer(
        alternative = false,
        thumbnailSize = thumbnailSize,
        modifier = modifier
            .background(backgroundColor)
            .let {
                if (clip) Modifier.clip(LocalAppearance.current.thumbnailShape) then it
                else it
            }
    ) {
        Box(
            modifier = Modifier.size(thumbnailSize),
            content = thumbnailContent
        )

        ItemInfoContainer {
            trailingContent?.let {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    BasicText(
                        text = title.orEmpty(),
                        style = typography.xs.semiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )

                    it()
                }
            } ?: BasicText(
                text = title.orEmpty(),
                style = typography.xs.semiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    authors?.let {
                        BasicText(
                            text = authors,
                            style = typography.xs.semiBold.secondary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(
                                weight = 1f,
                                fill = false
                            )
                        )
                    }

                    if (explicit) Image(
                        painter = painterResource(R.drawable.explicit),
                        contentDescription = null,
                        colorFilter = ColorFilter.tint(colorPalette.text),
                        modifier = Modifier.size(15.dp)
                    )
                }

                if (showDuration) duration?.let {
                    BasicText(
                        text = duration,
                        style = typography.xxs.secondary.medium,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
        }
    } else Unit
}

@Composable
fun SongItemPlaceholder(
    thumbnailSize: Dp,
    modifier: Modifier = Modifier
) = ItemContainer(
    alternative = false,
    thumbnailSize = thumbnailSize,
    modifier = modifier
) {
    val (colorPalette, _, _, thumbnailShape) = LocalAppearance.current

    Spacer(
        modifier = Modifier
            .background(color = colorPalette.shimmer, shape = thumbnailShape)
            .size(thumbnailSize)
    )

    ItemInfoContainer {
        TextPlaceholder()
        TextPlaceholder()
    }
}

private data class SongItemDisplay(
    val thumbnailUrl: String?,
    val title: String?,
    val authors: String?,
    val duration: String?,
    val explicit: Boolean
)

@Composable
private fun rememberSongItemDisplay(
    songId: String?,
    thumbnailSize: Dp,
    fallback: SongItemDisplay
): SongItemDisplay {
    if (songId.isNullOrBlank()) return fallback
    val songFlow = remember(songId) { Database.song(songId) }
    val storedSong by songFlow.collectAsState(initial = null)
    val song = storedSong ?: return fallback
    return SongItemDisplay(
        thumbnailUrl = song.thumbnailUrl?.thumbnail(thumbnailSize.px) ?: fallback.thumbnailUrl,
        title = song.title.ifBlank { fallback.title.orEmpty() },
        authors = song.artistsText ?: fallback.authors,
        duration = song.durationText ?: fallback.duration,
        explicit = song.explicit
    )
}
