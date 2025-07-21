package com.rmusic.android.ui.screens.home

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
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
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.isLandscape

@OptIn(ExperimentalFoundationApi::class)
@Route
@Composable
fun DownloadedArtistScreen(artistId: String) {
    val (colorPalette) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current
    
    val artist by Database.downloadedArtist(artistId).collectAsState(initial = null)
    val songs by Database.downloadedSongsByArtistId(artistId).collectAsState(initial = emptyList())
    val (currentMediaId, playing) = playingSong(binder)
    
    val lazyListState = rememberLazyListState()

    LayoutWithAdaptiveThumbnail(
        thumbnailContent = adaptiveThumbnailContent(
            isLoading = artist == null,
            url = artist?.thumbnailUrl
        ),
        modifier = Modifier.fillMaxSize()
    ) {
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
                item(
                    key = "header",
                    contentType = 0
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Header(
                            title = artist?.name ?: stringResource(R.string.unknown),
                            modifier = Modifier
                        ) {
                            SecondaryTextButton(
                                text = stringResource(R.string.enqueue),
                                enabled = songs.isNotEmpty(),
                                onClick = {
                                    binder?.player?.enqueue(songs.map { it.toSong().asMediaItem })
                                }
                            )
                        }

                        if (!isLandscape) {
                            // Thumbnail content will be shown here
                        }
                    }
                }

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
}
