package com.rmusic.android.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.Playlist
import com.rmusic.android.models.Song
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.InHistoryMediaItemMenu
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.forcePlayAtIndex
import com.rmusic.android.utils.playingSong
import com.rmusic.core.data.enums.BuiltInPlaylist
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.piped.models.PlaylistPreview as PipedPlaylistPreview
import com.rmusic.providers.piped.models.Session

@Route
@Composable
fun HomePlaylists(
    onBuiltInPlaylist: (BuiltInPlaylist) -> Unit,
    onPlaylistClick: (Playlist) -> Unit,
    onPipedPlaylistClick: (Session, PipedPlaylistPreview) -> Unit,
    onSearchClick: () -> Unit
) {
    val (colorPalette) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current

    // Only show history instead of all playlists
    val historySongs by Database.history().collectAsState(initial = emptyList())
    val (currentMediaId, playing) = playingSong(binder)

    val lazyListState = rememberLazyListState()

    Box {
        LazyColumn(
            state = lazyListState,
            contentPadding = LocalPlayerAwareWindowInsets.current
                .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                .asPaddingValues(),
            modifier = Modifier
                .fillMaxSize()
                .background(colorPalette.background0)
        ) {
            item(key = "header") {
                Header(title = stringResource(R.string.history)) {
                    HeaderIconButton(
                        icon = R.drawable.search,
                        color = colorPalette.text,
                        onClick = onSearchClick
                    )
                }
            }

            items(
                items = historySongs,
                key = Song::id
            ) { song ->
                SongItem(
                    song = song,
                    thumbnailSize = Dimensions.thumbnails.song,
                    modifier = Modifier
                        .clickable {
                            binder?.stopRadio()
                            binder?.player?.forcePlayAtIndex(
                                items = historySongs.map(Song::asMediaItem),
                                index = historySongs.indexOf(song)
                            )
                        }
                        .animateItem(),
                    isPlaying = playing && currentMediaId == song.id
                )
            }
        }

        FloatingActionsContainerWithScrollToTop(
            lazyListState = lazyListState,
            icon = R.drawable.search,
            onClick = onSearchClick
        )
    }
}
