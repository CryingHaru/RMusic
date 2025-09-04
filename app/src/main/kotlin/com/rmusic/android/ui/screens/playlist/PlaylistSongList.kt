package com.rmusic.android.ui.screens.playlist

import android.content.Intent
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.Playlist
import com.rmusic.android.models.SongPlaylistMap
import com.rmusic.android.query
import com.rmusic.android.transaction
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.ShimmerHost
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.HeaderPlaceholder
import com.rmusic.android.ui.components.themed.LayoutWithAdaptiveThumbnail
import com.rmusic.android.ui.components.themed.NonQueuedMediaItemMenu
import com.rmusic.android.ui.components.themed.PlaylistInfo
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.components.themed.TextFieldDialog
import com.rmusic.android.ui.components.themed.adaptiveThumbnailContent
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.ui.items.SongItemPlaceholder
import com.rmusic.android.utils.PlaylistDownloadIcon
import com.rmusic.android.utils.PlaylistDownloadIconSpecific
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.completed
import com.rmusic.android.utils.enqueue
import com.rmusic.android.utils.forcePlayAtIndex
import com.rmusic.android.utils.forcePlayFromBeginning
import com.rmusic.android.utils.playingSong
import com.rmusic.compose.persist.persist
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.isLandscape
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.models.bodies.BrowseBody
import com.rmusic.providers.innertube.requests.playlistPage
import com.rmusic.providers.ytmusic.YTMusicProvider
import com.rmusic.providers.ytmusic.pages.PlaylistResult
import com.valentinilk.shimmer.shimmer
import kotlinx.collections.immutable.toImmutableList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PlaylistSongList(
    browseId: String,
    params: String?,
    maxDepth: Int?,
    shouldDedup: Boolean,
    modifier: Modifier = Modifier
) {
    val (colorPalette) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val context = LocalContext.current
    val menuState = LocalMenuState.current

    var playlistPage by persist<Innertube.PlaylistOrAlbumPage?>("playlist/$browseId/playlistPage")
    var ytPlaylist by persist<PlaylistResult?>("playlist/$browseId/ytPlaylist")

    LaunchedEffect(Unit) {
        // Try YTMusic first (strip VL prefix if present)
        if (ytPlaylist == null) {
            val provider = YTMusicProvider.shared()
            if (provider.isLoggedIn()) {
                val id = browseId.removePrefix("VL")
                ytPlaylist = withContext(Dispatchers.IO) { provider.getPlaylist(id).getOrNull() }
            }
        }
        if (ytPlaylist == null && (playlistPage == null || playlistPage?.songsPage?.continuation != null)) {
            playlistPage = withContext(Dispatchers.IO) {
                Innertube
                    .playlistPage(BrowseBody(browseId = browseId, params = params))
                    ?.completed(
                        maxDepth = maxDepth ?: Int.MAX_VALUE,
                        shouldDedup = shouldDedup
                    )
                    ?.getOrNull()
            }
        }
    }

    var isImportingPlaylist by rememberSaveable { mutableStateOf(false) }

    if (isImportingPlaylist) TextFieldDialog(
        hintText = stringResource(R.string.enter_playlist_name_prompt),
        initialTextInput = playlistPage?.title.orEmpty(),
        onDismiss = { isImportingPlaylist = false },
        onAccept = { text ->
            query {
                transaction {
                    val playlistId = Database.insert(
                        Playlist(
                            name = text,
                            browseId = browseId,
                            thumbnail = playlistPage?.thumbnail?.url
                        )
                    )

                    playlistPage?.songsPage?.items
                        ?.map(Innertube.SongItem::asMediaItem)
                        ?.onEach(Database::insert)
                        ?.mapIndexed { index, mediaItem ->
                            SongPlaylistMap(
                                songId = mediaItem.mediaId,
                                playlistId = playlistId,
                                position = index
                            )
                        }?.let(Database::insertSongPlaylistMaps)
                }
            }
        }
    )

    val headerContent: @Composable () -> Unit = {
        val title = ytPlaylist?.title ?: playlistPage?.title
        if (title == null) HeaderPlaceholder(modifier = Modifier.shimmer())
        else Header(title = title ?: stringResource(R.string.unknown)) {
            SecondaryTextButton(
                text = stringResource(R.string.enqueue),
                enabled = (ytPlaylist?.tracks?.isNotEmpty() == true) || (playlistPage?.songsPage?.items?.isNotEmpty() == true),
                onClick = {
                    val mediaItems = ytPlaylist?.tracks?.map { it.asMediaItem }
                        ?: playlistPage?.songsPage?.items?.map(Innertube.SongItem::asMediaItem)
                    mediaItems?.let { binder?.player?.enqueue(it) }
                }
            )

            Spacer(modifier = Modifier.weight(1f))

            (ytPlaylist?.tracks?.map { it.asMediaItem }
                ?: playlistPage?.songsPage?.items?.map(Innertube.SongItem::asMediaItem))
                ?.let { mediaItems ->
                    PlaylistDownloadIconSpecific(
                        playlistId = browseId,
                        playlistName = title ?: "Unknown Playlist",
                        songs = mediaItems.toImmutableList()
                    )
                }

            HeaderIconButton(
                icon = R.drawable.add,
                color = colorPalette.text,
                onClick = { isImportingPlaylist = true }
            )

            HeaderIconButton(
                icon = R.drawable.share_social,
                color = colorPalette.text,
                onClick = {
                    val url = playlistPage?.url
                        ?: "https://music.youtube.com/playlist?list=${browseId.removePrefix("VL")}"

                    val sendIntent = Intent().apply {
                        action = Intent.ACTION_SEND
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, url)
                    }

                    context.startActivity(Intent.createChooser(sendIntent, null))
                }
            )
        }
    }

    val thumbnailContent = adaptiveThumbnailContent(
        isLoading = (playlistPage == null && ytPlaylist == null),
        url = ytPlaylist?.thumbnails?.firstOrNull()?.url ?: playlistPage?.thumbnail?.url
    )

    val lazyListState = rememberLazyListState()

    val (currentMediaId, playing) = playingSong(binder)

    // Precompute songs list (YTMusic preferred) so it's accessible for list + FAB
    val songsForList = ytPlaylist?.tracks?.map { it.asMediaItem } ?: playlistPage?.songsPage?.items?.map(Innertube.SongItem::asMediaItem)

    LayoutWithAdaptiveThumbnail(
        thumbnailContent = thumbnailContent,
        modifier = modifier
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
                        headerContent()
                        if (!isLandscape) thumbnailContent()
                        PlaylistInfo(playlist = playlistPage)
                    }
                }
                if (songsForList != null) itemsIndexed(items = songsForList) { index, mediaItem ->
                    SongItem(
                        song = mediaItem,
                        thumbnailSize = Dimensions.thumbnails.song,
                        modifier = Modifier
                            .combinedClickable(
                                onLongClick = {
                                    menuState.display {
                                        NonQueuedMediaItemMenu(
                                            onDismiss = menuState::hide,
                                            mediaItem = mediaItem
                                        )
                                    }
                                },
                                onClick = {
                                    songsForList.let { list ->
                                        binder?.stopRadio()
                                        binder?.player?.forcePlayAtIndex(list, index)
                                        // Autoplay: iniciar radio desde el tema seleccionado
                                        list.getOrNull(index)?.let { item ->
                                            binder?.setupRadio(
                                                com.rmusic.providers.innertube.models.NavigationEndpoint.Endpoint.Watch(
                                                    videoId = item.mediaId,
                                                    playlistId = null,
                                                    params = null,
                                                    playlistSetVideoId = null
                                                )
                                            )
                                        }
                                    }
                                }
                            ),
                        isPlaying = playing && currentMediaId == mediaItem.mediaId
                    )
                }

                if (playlistPage == null && ytPlaylist == null) item(key = "loading") {
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
                    songsForList?.let { songs ->
                        if (songs.isNotEmpty()) {
                            binder?.stopRadio()
                            binder?.player?.forcePlayFromBeginning(
                                songs.shuffled()
                            )
                            // Iniciar radio desde la primera canción tras shuffle
                            val first = songs.firstOrNull()?.mediaId
                            if (first != null) {
                                binder?.setupRadio(
                                    com.rmusic.providers.innertube.models.NavigationEndpoint.Endpoint.Watch(
                                        videoId = first,
                                        playlistId = null,
                                        params = null,
                                        playlistSetVideoId = null
                                    )
                                )
                            }
                        }
                    }
                }
            )
        }
    }
}
