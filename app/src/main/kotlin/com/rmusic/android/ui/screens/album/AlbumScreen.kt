package com.rmusic.android.ui.screens.album

import android.content.Intent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Spacer
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.rmusic.android.Database
import com.rmusic.android.R
import com.rmusic.android.models.Album
import com.rmusic.android.models.Song
import com.rmusic.android.models.SongAlbumMap
import com.rmusic.android.query
import com.rmusic.android.transaction
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.HeaderPlaceholder
import com.rmusic.android.ui.components.themed.PlaylistInfo
import com.rmusic.android.ui.components.themed.Scaffold
import com.rmusic.android.ui.components.themed.adaptiveThumbnailContent
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.utils.asMediaItem
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.persist.persist
import com.rmusic.compose.persist.persistList
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.stateFlowSaver
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.intermusic.pages.AlbumResult
import com.valentinilk.shimmer.shimmer
import kotlinx.collections.immutable.toImmutableList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.cancellable
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.withContext

@Route
@Composable
fun AlbumScreen(browseId: String) {
    val saveableStateHolder = rememberSaveableStateHolder()
    val navigationParams = remember { AlbumNavigationExtrasCache.consume(browseId) }

    val tabIndexState = rememberSaveable(saver = stateFlowSaver()) { MutableStateFlow(0) }
    val tabIndex by tabIndexState.collectAsState()

    var album by persist<Album?>("album/$browseId/album")
    var albumResult by persist<AlbumResult?>("album/$browseId/albumResult")
    var songs by persistList<Song>("album/$browseId/songs")

    PersistMapCleanup(prefix = "album/$browseId/")

    LaunchedEffect(Unit) {
        Database
            .albumSongs(browseId)
            .distinctUntilChanged()
            .combine(
                Database
                    .album(browseId)
                    .distinctUntilChanged()
                    .cancellable()
            ) { currentSongs, currentAlbum ->
                album = currentAlbum
                songs = currentSongs.toImmutableList()

                if (currentAlbum?.timestamp != null && currentSongs.isNotEmpty()) return@combine

                withContext(Dispatchers.IO) {
                    IntermusicProvider.shared()
                        .getAlbum(browseId, navigationParams)
                        .onSuccess { newAlbum ->
                            albumResult = newAlbum
                                            val artistSummary = newAlbum.artists
                                                .mapNotNull { it.name.takeIf(String::isNotBlank) }
                                                .joinToString(
                                                    separator = ", "
                                                )
                                                .takeIf { it.isNotBlank() }

                            transaction {
                                Database.clearAlbum(browseId)

                                Database.upsert(
                                    album = Album(
                                        id = browseId,
                                        title = newAlbum.title,
                                        description = newAlbum.description,
                                        thumbnailUrl = newAlbum.thumbnails.firstOrNull()?.url,
                                        year = newAlbum.year,
                                                        authorsText = artistSummary,
                                        shareUrl = "https://music.youtube.com/browse/${'$'}browseId",
                                        timestamp = System.currentTimeMillis(),
                                        bookmarkedAt = album?.bookmarkedAt,
                                                        otherInfo = artistSummary
                                    ),
                                    songAlbumMaps = newAlbum.tracks
                                        .map { it.asMediaItem }
                                        .onEach { Database.insert(it) }
                                        .mapIndexed { position, mediaItem ->
                                            SongAlbumMap(
                                                songId = mediaItem.mediaId,
                                                albumId = browseId,
                                                position = position
                                            )
                                        }
                                )
                            }
                        }
                        .onFailure { it.printStackTrace() }
                }
            }.collect()
    }

    RouteHandler {
        GlobalRoutes()

        Content {
            val headerContent: @Composable (
                beforeContent: (@Composable () -> Unit)?,
                afterContent: (@Composable () -> Unit)?
            ) -> Unit = { beforeContent, afterContent ->
                if (album?.timestamp == null) HeaderPlaceholder(modifier = Modifier.shimmer())
                else {
                    val (colorPalette) = LocalAppearance.current
                    val context = LocalContext.current

                    Header(title = album?.title ?: stringResource(R.string.unknown)) {
                        beforeContent?.invoke()

                        Spacer(modifier = Modifier.weight(1f))

                        afterContent?.invoke()

                        HeaderIconButton(
                            icon = if (album?.bookmarkedAt == null) R.drawable.bookmark_outline
                            else R.drawable.bookmark,
                            color = colorPalette.accent,
                            onClick = {
                                val bookmarkedAt =
                                    if (album?.bookmarkedAt == null) System.currentTimeMillis() else null

                                query {
                                    album
                                        ?.copy(bookmarkedAt = bookmarkedAt)
                                        ?.let(Database::update)
                                }
                            }
                        )

                        HeaderIconButton(
                            icon = R.drawable.share_social,
                            color = colorPalette.text,
                            onClick = {
                                album?.shareUrl?.let { url ->
                                    val sendIntent = Intent().apply {
                                        action = Intent.ACTION_SEND
                                        type = "text/plain"
                                        putExtra(Intent.EXTRA_TEXT, url)
                                    }

                                    context.startActivity(
                                        Intent.createChooser(sendIntent, null)
                                    )
                                }
                            }
                        )
                    }
                }
            }

            val thumbnailContent = adaptiveThumbnailContent(
                isLoading = album?.timestamp == null,
                url = album?.thumbnailUrl
            )

            Scaffold(
                key = "album",
                topIconButtonId = R.drawable.chevron_back,
                onTopIconButtonClick = pop,
                tabIndex = tabIndex,
                onTabChange = { newTab -> tabIndexState.update { newTab.coerceAtMost(0) } },
                tabColumnContent = {
                    tab(0, R.string.songs, R.drawable.musical_notes, canHide = false)
                }
            ) { currentTabIndex ->
                saveableStateHolder.SaveableStateProvider(key = currentTabIndex) {
                    AlbumSongs(
                        songs = songs,
                        album = album,
                        headerContent = headerContent,
                        thumbnailContent = thumbnailContent,
                        afterHeaderContent = {
                            if (album == null) PlaylistInfo(album = albumResult)
                            else PlaylistInfo(playlist = album)
                        }
                    )
                }
            }
        }
    }
}
