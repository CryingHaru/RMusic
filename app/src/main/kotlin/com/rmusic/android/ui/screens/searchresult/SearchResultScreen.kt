package com.rmusic.android.ui.screens.searchresult

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.runtime.Composable
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
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
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.models.bodies.ContinuationBody
import com.rmusic.providers.innertube.models.bodies.SearchBody
import com.rmusic.providers.innertube.requests.searchPage
import com.rmusic.providers.innertube.utils.from
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.innertube.models.NavigationEndpoint

@OptIn(ExperimentalFoundationApi::class)
@Route
@Composable
fun SearchResultScreen(query: String, onSearchAgain: () -> Unit) {
    val persistMap = LocalPersistMap.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current

    val saveableStateHolder = rememberSaveableStateHolder()
    var intermusicSearchResult by remember(query) { mutableStateOf<com.rmusic.providers.intermusic.pages.SearchResult?>(null) }
    LaunchedEffect(query) {
        val provider = IntermusicProvider.shared()
        if (provider.isLoggedIn()) {
            runCatching { provider.search(query).getOrNull() }
                .onSuccess { intermusicSearchResult = it }
        }
    }

    PersistMapCleanup(prefix = "searchResults/$query/")

    val (currentMediaId, playing) = playingSong(binder)

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
                    val intermusicResults = intermusicSearchResult
                    when (tabIndex) {
                        0 -> if (intermusicResults != null && intermusicResults.songs.isNotEmpty()) {
                            val lazyListState = rememberLazyListState()
                            val (currentMediaId2, playing2) = playingSong(binder)

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                itemsIndexed(intermusicResults.songs) { _, songResult ->
                                    val mediaItem = songResult.asMediaItem
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
                                                binder?.setupRadio(
                                                    com.rmusic.providers.innertube.models.NavigationEndpoint.Endpoint.Watch(
                                                        videoId = mediaItem.mediaId,
                                                        playlistId = null,
                                                        params = null,
                                                        playlistSetVideoId = null
                                                    )
                                                )
                                            }
                                        ),
                                        isPlaying = playing2 && currentMediaId2 == mediaItem.mediaId
                                    )
                                }
                            }
                        } else ItemsPage(
                            tag = "searchResults/$query/songs",
                            provider = { continuation ->
                                if (continuation == null) Innertube.searchPage(
                                    body = SearchBody(
                                        query = query,
                                        params = Innertube.SearchFilter.Song.value
                                    ),
                                    fromMusicShelfRendererContent = Innertube.SongItem.Companion::from
                                ) else Innertube.searchPage(
                                    body = ContinuationBody(continuation = continuation),
                                    fromMusicShelfRendererContent = Innertube.SongItem.Companion::from
                                )
                            },
                            emptyItemsText = stringResource(R.string.no_search_results),
                            header = headerContent,
                            itemContent = { song ->
                                SongItem(
                                    song = song,
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
                                            binder?.player?.forcePlay(song.asMediaItem)
                                            // Iniciar radio para reproducir recomendaciones automáticamente
                                            binder?.setupRadio(
                                                com.rmusic.providers.innertube.models.NavigationEndpoint.Endpoint.Watch(
                                                    videoId = song.asMediaItem.mediaId,
                                                    playlistId = null,
                                                    params = null,
                                                    playlistSetVideoId = null
                                                )
                                            )
                                        }
                                    ),
                                    isPlaying = playing && currentMediaId == song.key
                                )
                            },
                            itemPlaceholderContent = {
                                SongItemPlaceholder(thumbnailSize = Dimensions.thumbnails.song)
                            }
                        )

                        1 -> ItemsPage(
                            tag = "searchResults/$query/albums",
                            provider = { continuation ->
                                if (continuation == null) {
                                    Innertube.searchPage(
                                        body = SearchBody(
                                            query = query,
                                            params = Innertube.SearchFilter.Album.value
                                        ),
                                        fromMusicShelfRendererContent = Innertube.AlbumItem::from
                                    )
                                } else {
                                    Innertube.searchPage(
                                        body = ContinuationBody(continuation = continuation),
                                        fromMusicShelfRendererContent = Innertube.AlbumItem::from
                                    )
                                }
                            },
                            emptyItemsText = stringResource(R.string.no_search_results),
                            header = headerContent,
                            itemContent = { album ->
                                AlbumItem(
                                    album = album,
                                    thumbnailSize = Dimensions.thumbnails.album,
                                    modifier = Modifier.clickable(onClick = { albumRoute(album.key) })
                                )
                            },
                            itemPlaceholderContent = {
                                AlbumItemPlaceholder(thumbnailSize = Dimensions.thumbnails.album)
                            }
                        )

                        2 -> ItemsPage(
                            tag = "searchResults/$query/artists",
                            provider = { continuation ->
                                if (continuation == null) {
                                    Innertube.searchPage(
                                        body = SearchBody(
                                            query = query,
                                            params = Innertube.SearchFilter.Artist.value
                                        ),
                                        fromMusicShelfRendererContent = Innertube.ArtistItem::from
                                    )
                                } else {
                                    Innertube.searchPage(
                                        body = ContinuationBody(continuation = continuation),
                                        fromMusicShelfRendererContent = Innertube.ArtistItem::from
                                    )
                                }
                            },
                            emptyItemsText = stringResource(R.string.no_search_results),
                            header = headerContent,
                            itemContent = { artist ->
                                ArtistItem(
                                    artist = artist,
                                    thumbnailSize = 64.dp,
                                    modifier = Modifier
                                        .clickable(onClick = { artistRoute(artist.key) })
                                )
                            },
                            itemPlaceholderContent = {
                                ArtistItemPlaceholder(thumbnailSize = 64.dp)
                            }
                        )

                        3 -> ItemsPage(
                            tag = "searchResults/$query/videos",
                            provider = { continuation ->
                                if (continuation == null) Innertube.searchPage(
                                    body = SearchBody(
                                        query = query,
                                        params = Innertube.SearchFilter.Video.value
                                    ),
                                    fromMusicShelfRendererContent = Innertube.VideoItem::from
                                ) else Innertube.searchPage(
                                    body = ContinuationBody(continuation = continuation),
                                    fromMusicShelfRendererContent = Innertube.VideoItem::from
                                )
                            },
                            emptyItemsText = stringResource(R.string.no_search_results),
                            header = headerContent,
                            itemContent = { video ->
                                VideoItem(
                                    video = video,
                                    thumbnailWidth = 128.dp,
                                    thumbnailHeight = 72.dp,
                                    modifier = Modifier.combinedClickable(
                                        onLongClick = {
                                            menuState.display {
                                                NonQueuedMediaItemMenu(
                                                    mediaItem = video.asMediaItem,
                                                    onDismiss = menuState::hide
                                                )
                                            }
                                        },
                                        onClick = {
                                            binder?.stopRadio()
                                            binder?.player?.forcePlay(video.asMediaItem)
                                            // Iniciar radio desde el video cuando sea posible
                                            binder?.setupRadio(
                                                video.info?.endpoint ?: NavigationEndpoint.Endpoint.Watch(
                                                    videoId = video.asMediaItem.mediaId,
                                                    playlistId = null,
                                                    params = null,
                                                    playlistSetVideoId = null
                                                )
                                            )
                                        }
                                    )
                                )
                            },
                            itemPlaceholderContent = {
                                VideoItemPlaceholder(
                                    thumbnailWidth = 128.dp,
                                    thumbnailHeight = 72.dp
                                )
                            }
                        )

                        4 -> if (intermusicResults != null && intermusicResults.playlists.isNotEmpty()) {
                            val lazyListState = rememberLazyListState()

                            LazyColumn(
                                state = lazyListState,
                                contentPadding = com.rmusic.android.LocalPlayerAwareWindowInsets.current
                                    .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
                                    .asPaddingValues(),
                                modifier = Modifier.fillMaxSize()
                            ) {
                                item(key = "header") { headerContent(null) }
                                itemsIndexed(intermusicResults.playlists) { _, playlistResult ->
                                    PlaylistItem(
                                        thumbnailUrl = playlistResult.thumbnails.firstOrNull()?.url,
                                        songCount = playlistResult.songCount,
                                        name = playlistResult.title,
                                        channelName = playlistResult.author,
                                        thumbnailSize = Dimensions.thumbnails.playlist,
                                        modifier = Modifier.clickable {
                                            playlistRoute(playlistResult.browseId, null, null, false)
                                        }
                                    )
                                }
                            }
                        } else ItemsPage(
                            tag = "searchResults/$query/playlists",
                            provider = { continuation ->
                                if (continuation == null) Innertube.searchPage(
                                    body = SearchBody(
                                        query = query,
                                        params = Innertube.SearchFilter.CommunityPlaylist.value
                                    ),
                                    fromMusicShelfRendererContent = Innertube.PlaylistItem::from
                                ) else Innertube.searchPage(
                                    body = ContinuationBody(continuation = continuation),
                                    fromMusicShelfRendererContent = Innertube.PlaylistItem::from
                                )
                            },
                            emptyItemsText = stringResource(R.string.no_search_results),
                            header = headerContent,
                            itemContent = { playlist ->
                                PlaylistItem(
                                    playlist = playlist,
                                    thumbnailSize = Dimensions.thumbnails.playlist,
                                    modifier = Modifier.clickable {
                                        playlistRoute(playlist.key, null, null, false)
                                    }
                                )
                            },
                            itemPlaceholderContent = {
                                PlaylistItemPlaceholder(thumbnailSize = Dimensions.thumbnails.playlist)
                            }
                        )
                    }
                }
            }
        }
    }
}
