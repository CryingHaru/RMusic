package com.rmusic.android.ui.screens.searchresult

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.preferences.UIStatePreferences
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.NonQueuedMediaItemMenu
import com.rmusic.android.ui.components.themed.Scaffold
import com.rmusic.android.ui.items.AlbumItem
import com.rmusic.android.ui.items.AlbumItemPlaceholder
import com.rmusic.android.ui.items.ArtistItem
import com.rmusic.android.ui.items.ArtistItemPlaceholder
import com.rmusic.android.ui.items.PlaylistItem
import com.rmusic.android.ui.items.PlaylistItemPlaceholder
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.ui.items.SongItemPlaceholder
import com.rmusic.android.ui.items.VideoItem
import com.rmusic.android.ui.items.VideoItemPlaceholder
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.utils.forcePlay
import com.rmusic.android.utils.playingSong
import com.rmusic.android.utils.asMediaItem
import com.rmusic.compose.persist.LocalPersistMap
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.intermusic.IntermusicProvider

@OptIn(ExperimentalFoundationApi::class)
@Route
@Composable
fun SearchResultScreen(query: String, onSearchAgain: () -> Unit) {
    val persistMap = LocalPersistMap.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current

    val saveableStateHolder = rememberSaveableStateHolder()
    var intermusicSearchResult by remember(query) { mutableStateOf<com.rmusic.providers.intermusic.pages.SearchResult?>(null) }
    var isLoading by remember(query) { mutableStateOf(true) }
    var searchError by remember(query) { mutableStateOf<String?>(null) }

    LaunchedEffect(query) {
        isLoading = true
        searchError = null
        val provider = IntermusicProvider.shared()
        val result = provider.search(query)
        intermusicSearchResult = result.getOrNull()
        if (result.isFailure) {
            searchError = result.exceptionOrNull()?.localizedMessage
        }
        isLoading = false
    }

    PersistMapCleanup(prefix = "searchResults/$query/")
    RouteHandler {
        GlobalRoutes()

        Content {
            val headerContent: @Composable (textButton: (@Composable () -> Unit)?) -> Unit = {
                Header(
                    title = query,
                    modifier = Modifier.pointerInput(Unit) {
                        detectTapGestures {
                            persistMap?.clean("searchResults/$query/")
                            onSearchAgain()
                        }
                    }
                )
            }

            Scaffold(
                key = "searchresult",
                topIconButtonId = R.drawable.chevron_back,
                onTopIconButtonClick = pop,
                tabIndex = UIStatePreferences.searchResultScreenTabIndex,
                onTabChange = { UIStatePreferences.searchResultScreenTabIndex = it },
                tabColumnContent = {
                    tab(0, R.string.songs, R.drawable.musical_notes)
                    tab(1, R.string.albums, R.drawable.disc)
                    tab(2, R.string.artists, R.drawable.person)
                    tab(3, R.string.videos, R.drawable.film)
                    tab(4, R.string.playlists, R.drawable.playlist)
                }
            ) { tabIndex ->
                saveableStateHolder.SaveableStateProvider(tabIndex) {
                    val results = intermusicSearchResult
                    when (tabIndex) {
                        0 -> {
                            val lazyListState = rememberLazyListState()
                            val (currentMediaIdSongs, playingSongs) = playingSong(binder)
                            val songs = results?.songs

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                when {
                                    isLoading -> items(5, key = { "placeholder_song_$it" }) {
                                        SongItemPlaceholder(thumbnailSize = Dimensions.thumbnails.song)
                                    }

                                    searchError != null -> item(key = "error") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = searchError ?: stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    songs.isNullOrEmpty() -> item(key = "empty") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    else -> itemsIndexed(songs, key = { _, song -> song.videoId }) { _, song ->
                                        val mediaItem = song.asMediaItem
                                        SongItem(
                                            song = mediaItem,
                                            thumbnailSize = Dimensions.thumbnails.song,
                                            modifier = Modifier.combinedClickable(
                                                onLongClick = {
                                                    menuState.display {
                                                        NonQueuedMediaItemMenu(
                                                            onDismiss = menuState::hide,
                                                            mediaItem = mediaItem
                                                        )
                                                    }
                                                },
                                                onClick = {
                                                    binder?.stopRadio()
                                                    binder?.player?.forcePlay(mediaItem)
                                                    binder?.setupRadio(mediaItem.mediaId)
                                                }
                                            ),
                                            isPlaying = playingSongs && currentMediaIdSongs == mediaItem.mediaId
                                        )
                                    }
                                }
                            }
                        }

                        1 -> {
                            val lazyListState = rememberLazyListState()
                            val albums = results?.albums

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                when {
                                    isLoading -> items(6, key = { "placeholder_album_$it" }) {
                                        AlbumItemPlaceholder(thumbnailSize = Dimensions.thumbnails.album)
                                    }

                                    searchError != null -> item(key = "error") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = searchError ?: stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    albums.isNullOrEmpty() -> item(key = "empty") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    else -> items(albums, key = { it.browseId }) { album ->
                                        AlbumItem(
                                            album = album,
                                            thumbnailSize = Dimensions.thumbnails.album,
                                            modifier = Modifier.clickable { albumRoute(album.browseId) }
                                        )
                                    }
                                }
                            }
                        }

                        2 -> {
                            val lazyListState = rememberLazyListState()
                            val artists = results?.artists

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                when {
                                    isLoading -> items(6, key = { "placeholder_artist_$it" }) {
                                        ArtistItemPlaceholder(thumbnailSize = 64.dp)
                                    }

                                    searchError != null -> item(key = "error") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = searchError ?: stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    artists.isNullOrEmpty() -> item(key = "empty") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    else -> items(artists, key = { it.browseId ?: it.name }) { artist ->
                                        ArtistItem(
                                            artist = artist,
                                            thumbnailSize = 64.dp,
                                            modifier = Modifier.clickable(
                                                enabled = artist.browseId != null
                                            ) {
                                                artist.browseId?.let { artistRoute(it) }
                                            }
                                        )
                                    }
                                }
                            }
                        }

                        3 -> {
                            val lazyListState = rememberLazyListState()
                            val videos = results?.videos

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                when {
                                    isLoading -> items(6, key = { "placeholder_video_$it" }) {
                                        VideoItemPlaceholder(
                                            thumbnailWidth = 128.dp,
                                            thumbnailHeight = 72.dp
                                        )
                                    }

                                    searchError != null -> item(key = "error") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = searchError ?: stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    videos.isNullOrEmpty() -> item(key = "empty") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    else -> items(videos, key = { it.videoId }) { video ->
                                        val mediaItem = video.asMediaItem
                                        VideoItem(
                                            video = video,
                                            thumbnailWidth = 128.dp,
                                            thumbnailHeight = 72.dp,
                                            modifier = Modifier.combinedClickable(
                                                onLongClick = {
                                                    menuState.display {
                                                        NonQueuedMediaItemMenu(
                                                            mediaItem = mediaItem,
                                                            onDismiss = menuState::hide
                                                        )
                                                    }
                                                },
                                                onClick = {
                                                    binder?.stopRadio()
                                                    binder?.player?.forcePlay(mediaItem)
                                                    binder?.setupRadio(mediaItem.mediaId)
                                                }
                                            )
                                        )
                                    }
                                }
                            }
                        }

                        4 -> {
                            val lazyListState = rememberLazyListState()
                            val playlists = results?.playlists

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                when {
                                    isLoading -> items(6, key = { "placeholder_playlist_$it" }) {
                                        PlaylistItemPlaceholder(thumbnailSize = Dimensions.thumbnails.playlist)
                                    }

                                    searchError != null -> item(key = "error") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = searchError ?: stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    playlists.isNullOrEmpty() -> item(key = "empty") {
                                        val typography = LocalAppearance.current.typography
                                        BasicText(
                                            text = stringResource(R.string.no_search_results),
                                            style = typography.xs,
                                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 24.dp)
                                        )
                                    }

                                    else -> items(playlists, key = { it.browseId }) { playlistResult ->
                                        PlaylistItem(
                                            playlist = playlistResult,
                                            thumbnailSize = Dimensions.thumbnails.playlist,
                                            modifier = Modifier.clickable {
                                                playlistRoute(playlistResult.browseId, null, null, false)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
