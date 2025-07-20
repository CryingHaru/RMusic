package com.rmusic.android.ui.screens.home

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import coil3.compose.AsyncImage
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.DownloadedSong
import com.rmusic.android.service.downloadState
import com.rmusic.android.service.MusicDownloadService
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.LinearProgressIndicator
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.forcePlay
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.px
import com.rmusic.download.models.DownloadItem
import com.rmusic.download.DownloadState
import com.rmusic.download.DownloadManager
import com.rmusic.providers.innertube.models.NavigationEndpoint
import kotlinx.collections.immutable.toImmutableMap

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun HomeDownloads(onSearchClick: () -> Unit) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    
    val downloadedArtists by Database.downloadedArtists().collectAsState(initial = emptyList())
    val downloadsCount by Database.downloadedSongsCount().collectAsState(initial = 0)
    val totalSize by Database.totalDownloadedSize().collectAsState(initial = 0L)
    
    // Estado de descargas activas
    val activeDownloads by com.rmusic.android.service.activeDownloads.collectAsState()
    
    val lazyListState = rememberLazyListState()

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = lazyListState,
            contentPadding = LocalPlayerAwareWindowInsets.current
                .only(WindowInsetsSides.Vertical + WindowInsetsSides.End).asPaddingValues(),
            modifier = Modifier.fillMaxSize()
        ) {
            item(
                key = "header",
                contentType = 0
            ) {
                Header(
                    title = stringResource(R.string.downloads),
                    modifier = Modifier.padding(bottom = 8.dp)
                ) {
                    HeaderIconButton(
                        icon = R.drawable.search,
                        color = colorPalette.text,
                        onClick = onSearchClick
                    )
                }
            }

            // Active downloads section
            if (activeDownloads.isNotEmpty()) {
                item {
                    ActiveDownloadsSection(activeDownloads)
                }
            }

            // Download statistics
            if (downloadsCount > 0) {
                item(
                    key = "stats",
                    contentType = 1
                ) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp)
                    ) {
                        Column(
                            modifier = Modifier.padding(16.dp)
                        ) {
                            Text(
                                text = stringResource(R.string.download_statistics),
                                style = typography.m.copy(fontWeight = FontWeight.Bold),
                                color = colorPalette.text
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = "$downloadsCount ${stringResource(R.string.songs_downloaded)}",
                                style = typography.s,
                                color = colorPalette.textSecondary
                            )
                            if ((totalSize ?: 0) > 0) {
                                Text(
                                    text = "${formatFileSize(totalSize ?: 0)} ${stringResource(R.string.total_size)}",
                                    style = typography.s,
                                    color = colorPalette.textSecondary
                                )
                            }
                        }
                    }
                }
            }

            // Artist grid (Apple Music style)
            if (downloadedArtists.isNotEmpty()) {
                item(
                    key = "artists-header",
                    contentType = 2
                ) {
                    Text(
                        text = stringResource(R.string.artists),
                        style = typography.l.copy(fontWeight = FontWeight.Bold),
                        color = colorPalette.text,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                }

                itemsIndexed(
                    items = downloadedArtists.chunked(2),
                    key = { index, _ -> "artist-row-$index" }
                ) { _, artistPair ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        artistPair.forEach { artist ->
                            ArtistCard(
                                artist = artist,
                                onClick = { /* Navigate to artist downloads */ },
                                modifier = Modifier.weight(1f)
                            )
                        }
                        // Add empty space if odd number of artists
                        if (artistPair.size == 1) {
                            Spacer(modifier = Modifier.weight(1f))
                        }
                    }
                }
            } else if (activeDownloads.isEmpty()) {
                item(
                    key = "empty",
                    contentType = 3
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = stringResource(R.string.no_downloads_yet),
                            style = typography.l,
                            color = colorPalette.textSecondary
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = stringResource(R.string.download_music_to_see_here),
                            style = typography.s,
                            color = colorPalette.textDisabled
                        )
                    }
                }
            }
        }

        FloatingActionsContainerWithScrollToTop(lazyListState = lazyListState)
    }
}

@Composable
private fun ActiveDownloadsSection(downloads: List<DownloadItem>) {
    val (colorPalette, typography) = LocalAppearance.current
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = stringResource(R.string.active_downloads),
                style = typography.m.copy(fontWeight = FontWeight.Bold),
                color = colorPalette.text
            )
            Spacer(modifier = Modifier.height(12.dp))
            downloads.forEach { download ->
                DownloadItemRow(download)
                Spacer(modifier = Modifier.height(8.dp))
            }
        }
    }
}

@Composable
private fun DownloadItemRow(item: DownloadItem) {
    val context = LocalContext.current
    val (colorPalette, typography) = LocalAppearance.current
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth()
    ) {
        AsyncImage(
            model = item.thumbnailUrl,
            contentDescription = null,
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(4.dp))
        )
        Spacer(modifier = Modifier.size(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = item.title,
                style = typography.s,
                color = colorPalette.text,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            item.artist?.let {
                Text(
                    text = it,
                    style = typography.xs,
                    color = colorPalette.textSecondary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
            when (val state = item.state) {
                is DownloadState.Downloading -> {
                    LinearProgressIndicator(
                        progress = state.progress / 100f,
                        modifier = Modifier.fillMaxWidth().padding(top = 4.dp)
                    )
                }
                is DownloadState.Queued -> {
                    Text(
                        text = stringResource(R.string.queued),
                        style = typography.xs,
                        color = colorPalette.textDisabled,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
                is DownloadState.Paused -> {
                    Text(
                        text = stringResource(R.string.paused),
                        style = typography.xs,
                        color = colorPalette.textDisabled,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
                else -> {}
            }
        }
        Row {
            when (item.state) {
                is DownloadState.Downloading -> {
                    IconButton(onClick = { MusicDownloadService.pause(context, item.id) }) {
                        Icon(painterResource(R.drawable.pause), contentDescription = stringResource(R.string.pause))
                    }
                }
                is DownloadState.Paused -> {
                    IconButton(onClick = { MusicDownloadService.resume(context, item.id) }) {
                        Icon(painterResource(R.drawable.play), contentDescription = stringResource(R.string.play))
                    }
                }
                else -> {}
            }
            IconButton(onClick = { MusicDownloadService.cancel(context, item.id) }) {
                Icon(painterResource(R.drawable.close), contentDescription = stringResource(R.string.cancel))
            }
        }
    }
}

@Composable
private fun ArtistCard(
    artist: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val (colorPalette, typography) = LocalAppearance.current
    
    // Get first song by this artist for thumbnail
    val firstSong by Database.downloadedSongsByArtist(artist).collectAsState(initial = emptyList())
    val thumbnailUrl = firstSong.firstOrNull()?.thumbnailUrl
    
    Card(
        modifier = modifier
            .height(120.dp)
            .clickable { onClick() }
    ) {
        Box(
            modifier = Modifier.fillMaxSize()
        ) {
            // Background image
            AsyncImage(
                model = thumbnailUrl,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(8.dp))
            )
            
            // Gradient overlay
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        color = Color.Black.copy(alpha = 0.4f),
                        shape = RoundedCornerShape(8.dp)
                    )
            )
            
            // Artist name
            Text(
                text = artist,
                style = typography.s.copy(fontWeight = FontWeight.Bold),
                color = Color.White,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(12.dp)
            )
        }
    }
}

private fun formatFileSize(bytes: Long): String {
    val kb = bytes / 1024.0
    val mb = kb / 1024.0
    val gb = mb / 1024.0
    
    return when {
        gb >= 1 -> "%.1f GB".format(gb)
        mb >= 1 -> "%.1f MB".format(mb)
        else -> "%.1f KB".format(kb)
    }
}
