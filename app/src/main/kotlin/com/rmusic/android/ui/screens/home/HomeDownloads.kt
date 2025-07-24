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
import androidx.core.net.toUri
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
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
import com.rmusic.android.utils.forcePlayFromBeginning
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.px
import com.rmusic.core.ui.utils.songBundle
import com.rmusic.core.ui.utils.SongBundleAccessor
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

            // Download statistics with Apple Music style
            if (downloadsCount > 0) {
                item(
                    key = "stats",
                    contentType = 1
                ) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = androidx.compose.material3.CardDefaults.cardColors(
                            containerColor = if (colorPalette.isDark) 
                                colorPalette.background1 
                            else 
                                colorPalette.background2
                        )
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(20.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Music icon
                            Box(
                                modifier = Modifier
                                    .size(50.dp)
                                    .background(
                                        colorPalette.accent.copy(alpha = 0.1f),
                                        RoundedCornerShape(12.dp)
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    painter = painterResource(R.drawable.musical_notes),
                                    contentDescription = null,
                                    tint = colorPalette.accent,
                                    modifier = Modifier.size(24.dp)
                                )
                            }
                            
                            Spacer(modifier = Modifier.size(16.dp))
                            
                            Column {
                                Text(
                                    text = stringResource(R.string.downloaded_music),
                                    style = typography.l.copy(fontWeight = FontWeight.SemiBold),
                                    color = colorPalette.text
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "$downloadsCount songs • ${formatFileSize(totalSize ?: 0)}",
                                    style = typography.s,
                                    color = colorPalette.textSecondary
                                )
                            }
                        }
                    }
                }
            }

            // Album organization by artist (Apple Music style)
            if (downloadedArtists.isNotEmpty()) {
                items(
                    count = downloadedArtists.size,
                    key = { index -> downloadedArtists[index] }
                ) { index ->
                    val artist = downloadedArtists[index]
                    val songsByArtist by Database.downloadedSongsByArtist(artist).collectAsState(initial = emptyList())
                    val albumsByArtist by Database.downloadedAlbumsByArtist(artist).collectAsState(initial = emptyList())
                    
                    if (songsByArtist.isNotEmpty()) {
                        Column(modifier = Modifier.padding(vertical = 8.dp)) {
                            // Artist header with thumbnail
                            ArtistHeader(artist = artist)

                            // Show albums if available
                            if (albumsByArtist.isNotEmpty()) {
                                // Albums grid (Apple Music style)
                                LazyVerticalGrid(
                                    columns = GridCells.Fixed(2),
                                    contentPadding = PaddingValues(horizontal = 16.dp),
                                    verticalArrangement = Arrangement.spacedBy(12.dp),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                                    modifier = Modifier.height(((albumsByArtist.size / 2 + albumsByArtist.size % 2) * 200 + (albumsByArtist.size / 2) * 12).dp)
                                ) {
                                    items(albumsByArtist) { album ->
                                        AlbumCard(
                                            artist = artist,
                                            album = album,
                                            onClick = { /* Navigate to album downloads */ }
                                        )
                                    }
                                }
                            } else {
                                // Show individual songs if no albums
                                LazyColumn(
                                    modifier = Modifier.height(200.dp),
                                    contentPadding = PaddingValues(horizontal = 16.dp)
                                ) {
                                    items(
                                        count = songsByArtist.take(5).size,
                                        key = { index -> songsByArtist[index].id }
                                    ) { index ->
                                        SongDownloadItem(song = songsByArtist[index])
                                    }
                                    if (songsByArtist.size > 5) {
                                        item {
                                            Text(
                                                text = "+${songsByArtist.size - 5} more songs",
                                                style = typography.s,
                                                color = colorPalette.textSecondary,
                                                modifier = Modifier.padding(16.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (activeDownloads.isEmpty() && downloadedArtists.isEmpty()) {
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
            .padding(horizontal = 16.dp, vertical = 8.dp),
        colors = androidx.compose.material3.CardDefaults.cardColors(
            containerColor = if (colorPalette.isDark) 
                colorPalette.background1 
            else 
                colorPalette.background2
        )
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
private fun ArtistHeader(artist: String) {
    val (colorPalette, typography) = LocalAppearance.current
    // Get the first song by this artist to extract thumbnail info
    val songsByArtist by Database.downloadedSongsByArtist(artist).collectAsState(initial = emptyList())
    val firstSong = songsByArtist.firstOrNull()
    
    // Try to find artist thumbnail first, then fallback to song thumbnail
    val artistThumbnailUrl = firstSong?.let { song ->
        try {
            val songFile = java.io.File(song.filePath)
            val artistThumbnail = java.io.File(songFile.parentFile?.parentFile, "artist.jpg")
            if (artistThumbnail.exists()) {
                "file://${artistThumbnail.absolutePath}"
            } else {
                song.thumbnailUrl // Fallback to song thumbnail
            }
        } catch (e: Exception) {
            song.thumbnailUrl // Fallback on error
        }
    }
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = if (colorPalette.isDark) 
                    colorPalette.background1 
                else 
                    colorPalette.background2,
                shape = RoundedCornerShape(12.dp)
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Artist thumbnail - use the first song's thumbnail as fallback
        AsyncImage(
            model = artistThumbnailUrl,
            contentDescription = null,
            modifier = Modifier
                .size(60.dp)
                .clip(RoundedCornerShape(30.dp))
                .background(
                    color = if (colorPalette.isDark) 
                        colorPalette.background2 
                    else 
                        colorPalette.background1
                ),
            contentScale = ContentScale.Crop
        )
        
        Spacer(modifier = Modifier.size(16.dp))
        
        Column {
            Text(
                text = artist,
                style = typography.l.copy(fontWeight = FontWeight.Bold),
                color = colorPalette.text
            )
            
            Text(
                text = "${songsByArtist.size} songs",
                style = typography.s,
                color = colorPalette.textSecondary
            )
        }
    }
}

@Composable
private fun AlbumCard(
    artist: String,
    album: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    
    // Get first song by this artist and album for thumbnail
    val albumSongs by Database.downloadedSongsByArtistAndAlbum(artist, album).collectAsState(initial = emptyList())
    val firstSong = albumSongs.firstOrNull()
    val thumbnailUrl = firstSong?.albumThumbnailUrl ?: firstSong?.thumbnailUrl
    
    Card(
        modifier = modifier
            .height(200.dp)
            .clickable { 
                // Play the album when clicked
                if (albumSongs.isNotEmpty()) {
                    val mediaItems = albumSongs.map { song ->
                        MediaItem.Builder()
                            .setMediaMetadata(
                                MediaMetadata.Builder()
                                    .setTitle(song.title)
                                    .setArtist(song.artistsText)
                                    .setArtworkUri(song.thumbnailUrl?.toUri())
                                    .setExtras(
                                        SongBundleAccessor.bundle {
                                            durationText = song.durationText
                                            explicit = song.explicit
                                            albumId = song.albumId
                                            artistIds = song.artistIds?.split(",")?.map { it.trim() }
                                        }
                                    )
                                    .build()
                            )
                            .setMediaId(song.id)
                            .setUri("file://${song.filePath}".toUri())
                            .setCustomCacheKey(song.id)
                            .build()
                    }
                    binder?.player?.forcePlayFromBeginning(mediaItems)
                }
                onClick()
            },
        shape = RoundedCornerShape(12.dp),
        colors = androidx.compose.material3.CardDefaults.cardColors(
            containerColor = if (colorPalette.isDark) 
                colorPalette.background1 
            else 
                colorPalette.background2
        )
    ) {
        Column(
            modifier = Modifier.fillMaxSize()
        ) {
            // Album cover
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(150.dp)
            ) {
                AsyncImage(
                    model = thumbnailUrl,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .background(colorPalette.background2)
                )
                
                // Play button overlay (Apple Music style)
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.3f))
                        .clickable { 
                            // Play the album when play button is clicked
                            if (albumSongs.isNotEmpty()) {
                                val mediaItems = albumSongs.map { song ->
                                    MediaItem.Builder()
                                        .setMediaMetadata(
                                            MediaMetadata.Builder()
                                                .setTitle(song.title)
                                                .setArtist(song.artistsText)
                                                .setArtworkUri(song.thumbnailUrl?.toUri())
                                                .setExtras(
                                                    SongBundleAccessor.bundle {
                                                        durationText = song.durationText
                                                        explicit = song.explicit
                                                        albumId = song.albumId
                                                        artistIds = song.artistIds?.split(",")?.map { it.trim() }
                                                    }
                                                )
                                                .build()
                                        )
                                        .setMediaId(song.id)
                                        .setUri("file://${song.filePath}".toUri())
                                        .setCustomCacheKey(song.id)
                                        .build()
                                }
                                binder?.player?.forcePlayFromBeginning(mediaItems)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        painter = painterResource(R.drawable.play),
                        contentDescription = "Play",
                        tint = Color.White,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }
            
            // Album info
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(12.dp)
            ) {
                Text(
                    text = album,
                    style = typography.s.copy(fontWeight = FontWeight.SemiBold),
                    color = colorPalette.text,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                
                Text(
                    text = "${albumSongs.size} songs",
                    style = typography.xs,
                    color = colorPalette.textSecondary,
                    maxLines = 1
                )
            }
        }
    }
}

@Composable
private fun SongDownloadItem(song: DownloadedSong) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = if (colorPalette.isDark) 
                    colorPalette.background1 
                else 
                    colorPalette.background2,
                shape = RoundedCornerShape(8.dp)
            )
            .clickable {
                // Create a MediaItem with proper file URI for downloaded songs
                val mediaItem = MediaItem.Builder()
                    .setMediaMetadata(
                        MediaMetadata.Builder()
                            .setTitle(song.title)
                            .setArtist(song.artistsText)
                            .setArtworkUri(song.thumbnailUrl?.toUri())
                            .setExtras(
                                SongBundleAccessor.bundle {
                                    durationText = song.durationText
                                    explicit = song.explicit
                                    albumId = song.albumId
                                    artistIds = song.artistIds?.split(",")?.map { it.trim() }
                                }
                            )
                            .build()
                    )
                    .setMediaId(song.id)
                    .setUri("file://${song.filePath}".toUri()) // Use direct file path
                    .setCustomCacheKey(song.id)
                    .build()
                
                binder?.player?.forcePlay(mediaItem)
            }
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AsyncImage(
            model = song.thumbnailUrl,
            contentDescription = null,
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(4.dp))
                .background(
                    color = if (colorPalette.isDark) 
                        colorPalette.background2 
                    else 
                        colorPalette.background1
                )
        )
        
        Spacer(modifier = Modifier.size(12.dp))
        
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = song.title,
                style = typography.s,
                color = colorPalette.text,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            
            song.albumTitle?.let { albumTitle ->
                Text(
                    text = albumTitle,
                    style = typography.xs,
                    color = colorPalette.textSecondary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
        
        song.durationText?.let { duration ->
            Text(
                text = duration,
                style = typography.xs,
                color = colorPalette.textDisabled
            )
        }
    }
}

private fun formatFileSize(bytes: Long): String {
    return when {
        bytes >= 1024 * 1024 * 1024 -> "%.1f GB".format(bytes / (1024.0 * 1024.0 * 1024.0))
        bytes >= 1024 * 1024 -> "%.1f MB".format(bytes / (1024.0 * 1024.0))
        bytes >= 1024 -> "%.1f KB".format(bytes / 1024.0)
        else -> "$bytes B"
    }
}
