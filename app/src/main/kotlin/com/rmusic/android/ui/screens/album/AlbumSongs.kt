package com.rmusic.android.ui.screens.album

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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.Album
import com.rmusic.android.models.Song
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.ShimmerHost
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.LayoutWithAdaptiveThumbnail
import com.rmusic.android.ui.components.themed.NonQueuedMediaItemMenu
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.ui.items.SongItemPlaceholder
import com.rmusic.android.utils.AlbumDownloadIcon
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.enqueue
import com.rmusic.android.utils.forcePlayAtIndex
import com.rmusic.android.utils.forcePlayFromBeginning
import com.rmusic.android.utils.playingSong
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.isLandscape
import kotlinx.collections.immutable.ImmutableList
import kotlinx.collections.immutable.toImmutableList
import com.rmusic.android.service.MusicDownloadService

// TODO: migrate to single impl for all 'song lists'
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AlbumSongs(
    songs: ImmutableList<Song>,
    album: Album?,
    headerContent: @Composable (
        beforeContent: (@Composable () -> Unit)?,
        afterContent: (@Composable () -> Unit)?
    ) -> Unit,
    thumbnailContent: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    afterHeaderContent: (@Composable () -> Unit)? = null
) = LayoutWithAdaptiveThumbnail(
    thumbnailContent = thumbnailContent,
    modifier = modifier
) {
    val (colorPalette) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current
    val lazyListState = rememberLazyListState()

    val (currentMediaId, playing) = playingSong(binder)

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
                    headerContent(
                        {
                            SecondaryTextButton(
                                text = stringResource(R.string.enqueue),
                                enabled = songs.isNotEmpty(),
                                onClick = {
                                    binder?.player?.enqueue(songs.map(Song::asMediaItem))
                                }
                            )
                        },
                        {
                            album?.id?.let { albumId ->
                                album.title?.let { albumName ->
                                    AlbumDownloadIcon(
                                        songs = songs.map(Song::asMediaItem).toImmutableList(),
                                        albumId = albumId,
                                        albumName = albumName
                                    )
                                }
                            }
                        }
                    )

                    if (!isLandscape) thumbnailContent()
                    afterHeaderContent?.invoke()
                }
            }

            itemsIndexed(
                items = songs,
                key = { _, song -> song.id }
            ) { index, song ->
                SongItem(
                    song = song,
                    index = index,
                    thumbnailSize = Dimensions.thumbnails.song,
                    modifier = Modifier.combinedClickable(
                        onLongClick = {
                            menuState.display {
                                NonQueuedMediaItemMenu(
                                    onDismiss = menuState::hide,
                                    mediaItem = song.asMediaItem
                                )
                            }
                        },
                        onClick = {
                            binder?.stopRadio()
                            binder?.player?.forcePlayAtIndex(
                                items = songs.map(Song::asMediaItem),
                                index = index
                            )
                        }
                    ),
                    isPlaying = playing && currentMediaId == song.id
                )
            }

            if (songs.isEmpty()) item(key = "loading") {
                ShimmerHost(modifier = Modifier.fillParentMaxSize()) {
                    repeat(4) {
                        SongItemPlaceholder(thumbnailSize = Dimensions.thumbnails.song)
                    }
                }
            }
        }

        FloatingActionsContainerWithScrollToTop(
            lazyListState = lazyListState,
            icon = R.drawable.shuffle,
            onClick = {
                if (songs.isNotEmpty()) {
                    binder?.stopRadio()
                    binder?.player?.forcePlayFromBeginning(
                        songs.shuffled().map(Song::asMediaItem)
                    )
                }
            }
        )
    }
}
