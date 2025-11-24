package com.rmusic.android.ui.screens.mood

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.R
import com.rmusic.android.models.Mood
import com.rmusic.android.ui.components.ShimmerHost
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderPlaceholder
import com.rmusic.android.ui.components.themed.TextPlaceholder
import com.rmusic.android.ui.items.AlbumItem
import com.rmusic.android.ui.items.AlbumItemPlaceholder
import com.rmusic.android.ui.items.ArtistItem
import com.rmusic.android.ui.items.PlaylistItem
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.utils.center
import com.rmusic.android.utils.secondary
import com.rmusic.android.utils.semiBold
import com.rmusic.compose.persist.persist
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.intermusic.pages.SearchResult
import com.valentinilk.shimmer.shimmer

@Composable
fun MoodList(
    mood: Mood,
    modifier: Modifier = Modifier
) = Column(modifier = modifier) {
    val (colorPalette, typography) = LocalAppearance.current
    val windowInsets = LocalPlayerAwareWindowInsets.current

    val browseKey = mood.browseId ?: mood.name
    var moodSearch by persist<Result<SearchResult>>(
        tag = "playlist/mood/$browseKey${mood.params?.let { "/$it" }.orEmpty()}"
    )

    LaunchedEffect(browseKey, mood.name) {
        if (moodSearch?.isSuccess == true) return@LaunchedEffect

        moodSearch = IntermusicProvider.shared().search(mood.name)
    }

    val lazyListState = rememberLazyListState()

    val endPaddingValues = windowInsets
        .only(WindowInsetsSides.End)
        .asPaddingValues()

    val contentPadding = windowInsets
        .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
        .asPaddingValues()

    val sectionTextModifier = Modifier
        .padding(horizontal = 16.dp)
        .padding(top = 24.dp, bottom = 8.dp)
        .padding(endPaddingValues)

    moodSearch?.getOrNull()?.let { moodResult ->
        LazyColumn(
            state = lazyListState,
            contentPadding = contentPadding,
            modifier = Modifier
                .background(colorPalette.background0)
                .fillMaxSize()
        ) {
            item(
                key = "header",
                contentType = 0
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Header(title = mood.name)
                }
            }
            if (moodResult.albums.isNotEmpty()) {
                item(key = "albums_header") {
                    BasicText(
                        text = stringResource(R.string.albums),
                        style = typography.m.semiBold,
                        modifier = sectionTextModifier
                    )
                }
                item(key = "albums_list") {
                    LazyRow {
                        items(
                            items = moodResult.albums,
                            key = { it.browseId }
                        ) { album ->
                            AlbumItem(
                                album = album,
                                thumbnailSize = Dimensions.thumbnails.album,
                                alternative = true,
                                modifier = Modifier.clickable {
                                    album.browseId.takeUnless { it.isNullOrEmpty() }?.let {
                                        albumRoute.global(it)
                                    }
                                }
                            )
                        }
                    }
                }
            }

            if (moodResult.artists.isNotEmpty()) {
                item(key = "artists_header") {
                    BasicText(
                        text = stringResource(R.string.artists),
                        style = typography.m.semiBold,
                        modifier = sectionTextModifier
                    )
                }
                item(key = "artists_list") {
                    LazyRow {
                        items(
                            items = moodResult.artists,
                            key = { it.browseId ?: it.name }
                        ) { artist ->
                            ArtistItem(
                                artist = artist,
                                thumbnailSize = Dimensions.thumbnails.album,
                                alternative = true,
                                modifier = Modifier.clickable {
                                    artist.browseId?.let { artistRoute.global(it) }
                                }
                            )
                        }
                    }
                }
            }

            if (moodResult.playlists.isNotEmpty()) {
                item(key = "playlists_header") {
                    BasicText(
                        text = stringResource(R.string.playlists),
                        style = typography.m.semiBold,
                        modifier = sectionTextModifier
                    )
                }
                item(key = "playlists_list") {
                    LazyRow {
                        items(
                            items = moodResult.playlists,
                            key = { it.browseId }
                        ) { playlist ->
                            PlaylistItem(
                                playlist = playlist,
                                thumbnailSize = Dimensions.thumbnails.album,
                                alternative = true,
                                modifier = Modifier.clickable {
                                    playlistRoute.global(
                                        p0 = playlist.browseId,
                                        p1 = null,
                                        p2 = playlist.songCount?.let { it / 100 },
                                        p3 = true
                                    )
                                }
                            )
                        }
                    }
                }
            }
        }
    } ?: moodSearch?.exceptionOrNull()?.let {
        BasicText(
            text = stringResource(R.string.error_message),
            style = typography.s.secondary.center,
            modifier = Modifier
                .align(Alignment.CenterHorizontally)
                .padding(all = 16.dp)
        )
    } ?: ShimmerHost(modifier = Modifier.padding(contentPadding)) {
        HeaderPlaceholder(modifier = Modifier.shimmer())
        repeat(4) {
            TextPlaceholder(modifier = sectionTextModifier)
            Row {
                repeat(6) {
                    AlbumItemPlaceholder(
                        thumbnailSize = Dimensions.thumbnails.album,
                        alternative = true
                    )
                }
            }
        }
    }
}
