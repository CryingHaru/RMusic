package com.rmusic.android.ui.components.themed

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.rmusic.android.models.Album
import com.rmusic.android.utils.semiBold
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.intermusic.pages.AlbumResult as InterAlbumResult

@Composable
fun PlaylistInfo(
    description: String?,
    year: String?,
    otherInfo: String?,
    modifier: Modifier = Modifier
) {
    val (_, typography) = LocalAppearance.current

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier.padding(horizontal = 8.dp)
    ) {
        otherInfo?.let { info ->
            BasicText(
                text = info,
                style = typography.s.semiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                softWrap = false
            )
        }

        year?.let { year ->
            BasicText(
                text = year,
                style = typography.s.semiBold,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                softWrap = false
            )
        }

        description?.let { description ->
            Attribution(text = description)
        }
    }
}

@Composable
fun PlaylistInfo(
    playlist: Album?,
    modifier: Modifier = Modifier
) = PlaylistInfo(
    description = playlist?.description,
    year = playlist?.year,
    otherInfo = playlist?.otherInfo ?: playlist?.authorsText,
    modifier = modifier
)

@Composable
fun PlaylistInfo(
    album: InterAlbumResult?,
    modifier: Modifier = Modifier
) = PlaylistInfo(
    description = album?.description,
    year = album?.year,
    otherInfo = album?.artists
        ?.mapNotNull { artist -> artist.name.takeIf { it.isNotBlank() } }
        ?.takeIf { it.isNotEmpty() }
        ?.joinToString(", "),
    modifier = modifier
)
