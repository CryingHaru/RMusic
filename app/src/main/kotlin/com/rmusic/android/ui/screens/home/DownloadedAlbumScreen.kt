package com.rmusic.android.ui.screens.home

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.InHistoryMediaItemMenu
import com.rmusic.android.ui.components.themed.LayoutWithAdaptiveThumbnail
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.components.themed.adaptiveThumbnailContent
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.enqueue
import com.rmusic.android.utils.forcePlayAtIndex
import com.rmusic.android.utils.forcePlayFromBeginning
import com.rmusic.android.utils.playingSong
import com.rmusic.android.utils.semiBold
import com.rmusic.android.utils.secondary
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.isLandscape

@OptIn(ExperimentalFoundationApi::class)
@Route
@Composable
fun DownloadedAlbumScreen(albumId: String) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current
    val context = LocalContext.current
    
    val album by Database.downloadedAlbum(albumId).collectAsState(initial = null)
    val songs by Database.downloadedSongsByAlbumId(albumId).collectAsState(initial = emptyList())
    val (currentMediaId, playing) = playingSong(binder)
    
    val lazyListState = rememberLazyListState()

    Box {
        LazyColumn(
            state = lazyListState,
            contentPadding = LocalPlayerAwareWindowInsets.current
                .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                .asPaddingValues(),
            modifier = Modifier
                .background(colorPalette.background0)
                .fillMaxSize()
        ) {
            // Apple Music style header
            item(
                key = "header",
                contentType = 0
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp)
                ) {
                    // Album cover (centered)
                    AsyncImage(
                        model = album?.let { albumData ->
                            // Try to use local cover from app's internal directory first, fallback to URL
                            val albumsImageDir = java.io.File(context.filesDir, "albums")
                            val localCoverFile = java.io.File(albumsImageDir, "${albumData.id}.jpg")
                            if (localCoverFile.exists()) {
                                "file://${localCoverFile.absolutePath}"
                            } else {
                                albumData.thumbnailUrl
                            }
                        },
                        contentDescription = album?.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .size(300.dp)
                            .clip(RoundedCornerShape(12.dp))
                    )
                    
                    // Album title (centered below cover)
                    BasicText(
                        text = album?.title ?: stringResource(R.string.unknown),
                        style = typography.xxl.semiBold.copy(
                            color = colorPalette.text,
                            fontSize = 28.sp,
                            textAlign = TextAlign.Center
                        ),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    // Artist name(s) (centered below title)
                    album?.authorsText?.let { artistText ->
                        BasicText(
                            text = artistText,
                            style = typography.l.secondary.copy(
                                color = colorPalette.textSecondary,
                                fontSize = 20.sp,
                                textAlign = TextAlign.Center
                            ),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                    
                    // Additional info (year, song count)
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        album?.year?.let { year ->
                            BasicText(
                                text = year,
                                style = typography.s.secondary.copy(
                                    color = colorPalette.textDisabled,
                                    fontSize = 16.sp
                                )
                            )
                        }
                        
                        if (songs.isNotEmpty()) {
                            BasicText(
                                text = "${songs.size} ${if (songs.size == 1) "song" else "songs"}",
                                style = typography.s.secondary.copy(
                                    color = colorPalette.textDisabled,
                                    fontSize = 16.sp
                                )
                            )
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(8.dp))
                    
                    // Action buttons
                    SecondaryTextButton(
                        text = stringResource(R.string.enqueue),
                        enabled = songs.isNotEmpty(),
                        onClick = {
                            binder?.player?.enqueue(songs.map { it.toSong().asMediaItem })
                        }
                    )
                }
            }

            // Downloaded songs list
            itemsIndexed(
                items = songs,
                key = { _, song -> song.id }
            ) { index, downloadedSong ->
                val song = downloadedSong.toSong()
                SongItem(
                    song = song,
                    index = index,
                    thumbnailSize = Dimensions.thumbnails.song,
                    modifier = Modifier.combinedClickable(
                        onLongClick = {
                            menuState.display {
                                InHistoryMediaItemMenu(
                                    song = song,
                                    onDismiss = menuState::hide
                                )
                            }
                        },
                        onClick = {
                            binder?.stopRadio()
                            binder?.player?.forcePlayAtIndex(
                                items = songs.map { it.toSong().asMediaItem },
                                index = index
                            )
                        }
                    ),
                    isPlaying = playing && currentMediaId == song.id
                )
            }
        }

        FloatingActionsContainerWithScrollToTop(
            lazyListState = lazyListState,
            icon = R.drawable.shuffle,
            onClick = {
                if (songs.isNotEmpty()) {
                    binder?.stopRadio()
                    binder?.player?.forcePlayFromBeginning(
                        songs.shuffled().map { it.toSong().asMediaItem }
                    )
                }
            }
        )
    }
}
