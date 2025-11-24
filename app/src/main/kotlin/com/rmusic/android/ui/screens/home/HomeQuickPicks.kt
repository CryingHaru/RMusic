package com.rmusic.android.ui.screens.home

import androidx.annotation.StringRes
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Alignment
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.Song
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.preferences.QuickPicksSnapshot
import com.rmusic.android.preferences.hasSections
import com.rmusic.android.preferences.toCachedSections
import com.rmusic.android.preferences.toHomeSections
import com.rmusic.android.ui.components.ShimmerHost
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.album.AlbumNavigationExtrasCache
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.utils.DeviceConstraints
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.forcePlay
import com.rmusic.android.utils.playingSong
import com.rmusic.android.utils.thumbnail
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.utils.px
import coil3.compose.AsyncImage
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.intermusic.pages.HomeItem
import com.rmusic.providers.intermusic.pages.HomeSection
import java.util.LinkedHashSet

private const val HOME_SECTION_PAGES_PER_LOAD = 3

@Route
@Composable
fun QuickPicks(
    onSearchClick: () -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val windowInsets = LocalPlayerAwareWindowInsets.current
    val provider = remember { IntermusicProvider.shared() }
    val context = LocalContext.current

    var homeSections by remember { mutableStateOf<List<HomeSectionSlice>>(emptyList()) }
    var homeSectionModels by remember { mutableStateOf<List<HomeSection>>(emptyList()) }
    var homeSectionsLoading by remember { mutableStateOf(false) }
    var isRefreshingHome by remember { mutableStateOf(false) }
    var homeSectionsError by remember { mutableStateOf<String?>(null) }
    var isAppendingSections by remember { mutableStateOf(false) }
    var hasPendingContinuations by remember { mutableStateOf(false) }
    var sectionCounter by remember { mutableStateOf(0) }
    var nextContinuationToken by remember { mutableStateOf<String?>(null) }
    var hasRestoredSnapshot by remember { mutableStateOf(false) }
    val cookies = DataPreferences.cookies

    suspend fun loadHomeSections(reset: Boolean) {
        val shouldShowFullScreenLoading = reset && homeSections.isEmpty()
        val shouldShowRefresh = reset && homeSections.isNotEmpty()
        val shouldAppend = !reset

        when {
            shouldShowFullScreenLoading -> homeSectionsLoading = true
            shouldShowRefresh -> isRefreshingHome = true
            shouldAppend -> isAppendingSections = true
        }

        val previousSections = homeSections
        val previousModels = homeSectionModels
        if (reset) {
            sectionCounter = 0
        }

        var token = if (reset) null else nextContinuationToken
        if (!reset && token == null) {
            isAppendingSections = false
            hasPendingContinuations = false
            return
        }

        var pagesFetched = 0
        var updatedSections = if (reset) emptyList<HomeSectionSlice>() else homeSections
        var updatedModels = if (reset) emptyList<HomeSection>() else homeSectionModels
        var offset = sectionCounter
        var pendingToken: String? = token
        var encounteredError: String? = null

        while (pagesFetched < HOME_SECTION_PAGES_PER_LOAD && (pendingToken != null || (reset && pagesFetched == 0))) {
            val fetchToken = if (reset && pagesFetched == 0) null else pendingToken
            val result = provider.getHome(fetchToken)
            val home = result.getOrElse { throwable ->
                encounteredError = throwable.localizedMessage
                    ?: throwable.message
                    ?: context.getString(R.string.error_loading_content)
                break
            }

            val newSlices = home.sections.flatMapIndexed { index, section ->
                section.toSlices(offset + index)
            }
            if (newSlices.isNotEmpty()) {
                val combined = if (reset && pagesFetched == 0) newSlices else updatedSections + newSlices
                updatedSections = combined.sortedByTypeAndSection()
            }
            if (home.sections.isNotEmpty()) {
                updatedModels = if (reset && pagesFetched == 0) home.sections else updatedModels + home.sections
            }
            offset += home.sections.size
            pendingToken = home.continuationTokens.firstOrNull()
            pagesFetched++

            if (pendingToken == null) break
        }

        if (encounteredError == null || updatedSections.isNotEmpty()) {
            homeSections = updatedSections
            homeSectionModels = updatedModels
            sectionCounter = updatedModels.size
        } else if (reset) {
            homeSections = previousSections
            homeSectionModels = previousModels
        }

        nextContinuationToken = pendingToken
        hasPendingContinuations = pendingToken != null
        homeSectionsError = encounteredError

        if (DataPreferences.shouldCacheQuickPicks && homeSectionModels.isNotEmpty()) {
            val existingSnapshot = DataPreferences.quickPicksSnapshot
            DataPreferences.quickPicksSnapshot = existingSnapshot.copy(
                sections = homeSectionModels.toCachedSections(),
                timestamp = System.currentTimeMillis(),
                continuationToken = pendingToken
            )
        }

        when {
            shouldShowFullScreenLoading -> homeSectionsLoading = false
            shouldShowRefresh -> isRefreshingHome = false
            shouldAppend -> isAppendingSections = false
        }
    }

    LaunchedEffect(cookies) {
        if (homeSections.isNotEmpty()) {
            loadHomeSections(reset = true)
        }
    }

    LaunchedEffect(Unit) {
        if (!DeviceConstraints.quickPicksEnabled) return@LaunchedEffect
        if (!DataPreferences.shouldCacheQuickPicks) {
            hasRestoredSnapshot = true
            return@LaunchedEffect
        }
        if (hasRestoredSnapshot) return@LaunchedEffect
        val snapshot = DataPreferences.quickPicksSnapshot
        if (snapshot.hasSections()) {
            val restoredSections = snapshot.toHomeSections()
            homeSectionModels = restoredSections
            homeSections = restoredSections.flatMapIndexed { index, section ->
                section.toSlices(index)
            }.sortedByTypeAndSection()
            sectionCounter = restoredSections.size
            nextContinuationToken = snapshot.continuationToken
            hasPendingContinuations = snapshot.continuationToken != null
        }
        hasRestoredSnapshot = true
    }

    LaunchedEffect(homeSections.isEmpty()) {
        if (DeviceConstraints.quickPicksEnabled && homeSections.isEmpty()) {
            loadHomeSections(reset = true)
        }
    }

    val onSongClick: (Song) -> Unit = { song ->
        val mediaItem = song.asMediaItem
        binder?.stopRadio()
        binder?.player?.forcePlay(mediaItem)
        binder?.setupRadio(mediaItem.mediaId)
    }

    val onAlbumClick: (HomeAlbum) -> Unit = { album ->
        AlbumNavigationExtrasCache.put(album.id, album.params)
        albumRoute.global(album.id)
    }

    val onPlaylistClick: (HomePlaylist) -> Unit = { playlist ->
        playlistRoute.global(playlist.id, playlist.params, null, false)
    }

    val onArtistClick: (HomeArtist) -> Unit = { artist ->
        artistRoute.global(artist.id)
    }

    if (!DeviceConstraints.quickPicksEnabled) {
        Column(
            modifier = Modifier
                .background(colorPalette.background0)
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            BasicText(
                text = stringResource(R.string.quick_picks_disabled_low_spec),
                style = typography.m.copy(color = colorPalette.textSecondary)
            )
        }
        return
    }

    val scrollState = rememberScrollState()
    val endPaddingValues = windowInsets.only(WindowInsetsSides.End).asPaddingValues()
    val (currentMediaId, playing) = playingSong(binder)

    // Detect when scrolled to bottom for infinite scroll
    val isAtBottom by remember {
        derivedStateOf {
            val maxScroll = scrollState.maxValue
            val currentScroll = scrollState.value
            maxScroll > 0 && currentScroll >= maxScroll - 200
        }
    }

    // Load more when reaching bottom
    LaunchedEffect(isAtBottom, hasPendingContinuations, isAppendingSections, homeSectionsLoading) {
        if (isAtBottom && hasPendingContinuations && !isAppendingSections && !homeSectionsLoading) {
            loadHomeSections(reset = false)
        }
    }

    // Triggers for safe coroutine launching
    var refreshTrigger by remember { mutableStateOf(0) }
    var loadMoreTrigger by remember { mutableStateOf(0) }
    var retryTrigger by remember { mutableStateOf(0) }
    
    LaunchedEffect(refreshTrigger) {
        if (refreshTrigger > 0) {
            loadHomeSections(reset = true)
        }
    }
    
    LaunchedEffect(loadMoreTrigger) {
        if (loadMoreTrigger > 0 && hasPendingContinuations && !isAppendingSections) {
            loadHomeSections(reset = false)
        }
    }
    
    LaunchedEffect(retryTrigger) {
        if (retryTrigger > 0) {
            homeSectionsError = null
            loadHomeSections(reset = true)
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    BoxWithConstraints {
        PullToRefreshBox(
            isRefreshing = isRefreshingHome,
            onRefresh = { refreshTrigger++ },
            modifier = Modifier
                .background(colorPalette.background0)
                .fillMaxSize()
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(scrollState)
                    .padding(
                        windowInsets
                            .only(WindowInsetsSides.Vertical)
                            .asPaddingValues()
                    )
            ) {
                Spacer(modifier = Modifier.height(16.dp))

                HomeSectionsBlock(
                    sections = homeSections,
                    isLoading = homeSectionsLoading,
                    isRefreshing = isRefreshingHome,
                    isAppending = isAppendingSections,
                    hasPending = hasPendingContinuations,
                    errorMessage = homeSectionsError,
                    endPadding = endPaddingValues,
                    currentMediaId = currentMediaId,
                    isPlaying = playing,
                    onLoadMore = { loadMoreTrigger++ },
                    onRetry = { retryTrigger++ },
                    onSongClick = onSongClick,
                    onAlbumClick = onAlbumClick,
                    onPlaylistClick = onPlaylistClick,
                    onArtistClick = onArtistClick
                )
            }
        }

        FloatingActionsContainerWithScrollToTop(
            scrollState = scrollState,
            icon = R.drawable.search,
            onClick = onSearchClick
        )
    }
}

@Composable
private fun HomeSectionsBlock(
    sections: List<HomeSectionSlice>,
    isLoading: Boolean,
    isRefreshing: Boolean,
    isAppending: Boolean,
    hasPending: Boolean,
    errorMessage: String?,
    endPadding: PaddingValues,
    currentMediaId: String?,
    isPlaying: Boolean,
    onLoadMore: () -> Unit,
    onRetry: () -> Unit,
    onSongClick: (Song) -> Unit,
    onAlbumClick: (HomeAlbum) -> Unit,
    onPlaylistClick: (HomePlaylist) -> Unit,
    onArtistClick: (HomeArtist) -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val layoutDirection = LocalLayoutDirection.current
    val hasSections = sections.isNotEmpty()

    when {
        isLoading && !hasSections -> HomeSectionsPlaceholder(endPadding)

        !hasSections && errorMessage != null -> {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .padding(end = endPadding.calculateEndPadding(layoutDirection))
            ) {
                BasicText(
                    text = errorMessage,
                    style = typography.m
                )
                SecondaryTextButton(
                    text = stringResource(R.string.sync),
                    enabled = !isRefreshing,
                    onClick = onRetry,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }

        !hasSections -> {
            BasicText(
                text = stringResource(R.string.no_items_found),
                style = typography.m,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .padding(end = endPadding.calculateEndPadding(layoutDirection))
            )
        }

        else -> {
            sections.forEach { section ->
                HomeSectionSliceRow(
                    section = section,
                    endPadding = endPadding,
                    currentMediaId = currentMediaId,
                    isPlaying = isPlaying,
                    onSongClick = onSongClick,
                    onAlbumClick = onAlbumClick,
                    onPlaylistClick = onPlaylistClick,
                    onArtistClick = onArtistClick
                )
            }

            when {
                isAppending -> HomeSectionInlinePlaceholder(endPadding)
                hasPending -> {
                    SecondaryTextButton(
                        text = stringResource(R.string.sync),
                        enabled = !isRefreshing && !isAppending,
                        onClick = onLoadMore,
                        modifier = Modifier
                            .padding(horizontal = 16.dp, vertical = 8.dp)
                            .padding(end = endPadding.calculateEndPadding(layoutDirection))
                    )
                }
            }

            errorMessage?.let { message ->
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                        .padding(end = endPadding.calculateEndPadding(layoutDirection))
                ) {
                    BasicText(
                        text = message,
                        style = typography.s.copy(color = colorPalette.textSecondary)
                    )
                    SecondaryTextButton(
                        text = stringResource(R.string.sync),
                        enabled = !isRefreshing,
                        onClick = onRetry,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun HomeSectionSliceRow(
    section: HomeSectionSlice,
    endPadding: PaddingValues,
    currentMediaId: String?,
    isPlaying: Boolean,
    onSongClick: (Song) -> Unit,
    onAlbumClick: (HomeAlbum) -> Unit,
    onPlaylistClick: (HomePlaylist) -> Unit,
    onArtistClick: (HomeArtist) -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val layoutDirection = LocalLayoutDirection.current
    val insetEnd = endPadding.calculateEndPadding(layoutDirection)
    val suffix = section.suffixRes?.let { stringResource(id = it) }
    val displayTitle = when {
        section.title.isNullOrBlank() && suffix.isNullOrBlank() -> null
        section.title.isNullOrBlank() -> suffix
        suffix.isNullOrBlank() -> section.title
        else -> stringResource(R.string.home_section_suffix, section.title!!, suffix!!)
    }
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp)
            .padding(end = insetEnd)
    ) {
        displayTitle?.let { title ->
            BasicText(
                text = title,
                style = typography.m.copy(
                    color = colorPalette.text
                ),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(bottom = 12.dp, start = 4.dp)
            )
        }

        when (section.type) {
            HomeSectionSliceType.Songs -> HomeSongRow(
                songs = section.songs,
                currentMediaId = currentMediaId,
                isPlaying = isPlaying,
                onSongClick = onSongClick
            )

            HomeSectionSliceType.Albums -> HomeAlbumRow(
                albums = section.albums,
                onAlbumClick = onAlbumClick
            )

            HomeSectionSliceType.Playlists -> HomePlaylistRow(
                playlists = section.playlists,
                onPlaylistClick = onPlaylistClick
            )

            HomeSectionSliceType.Artists -> HomeArtistRow(
                artists = section.artists,
                onArtistClick = onArtistClick
            )
        }
    }
}

@Composable
private fun HomeSongRow(
    songs: List<Song>,
    currentMediaId: String?,
    isPlaying: Boolean,
    onSongClick: (Song) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(horizontal = 2.dp)
    ) {
        items(songs, key = { it.id }) { song ->
            HomeSongCard(
                song = song,
                isActive = isPlaying && currentMediaId == song.id,
                onClick = { onSongClick(song) }
            )
        }
    }
}

@Composable
private fun HomeSongCard(
    song: Song,
    isActive: Boolean,
    onClick: () -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val artworkShape = RoundedCornerShape(8.dp)

    Column(
        modifier = Modifier
            .width(140.dp)
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(artworkShape)
                .background(colorPalette.background1)
        ) {
            val imageModel = song.thumbnailUrl?.thumbnail(Dimensions.thumbnails.playlist.px)
            if (imageModel != null) {
                AsyncImage(
                    model = imageModel,
                    contentDescription = song.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }

            if (isActive) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.3f))
                )
                Box(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(colorPalette.accent),
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        modifier = Modifier
                            .size(12.dp)
                            .clip(CircleShape)
                            .background(Color.White)
                    )
                }
            }
        }

        BasicText(
            text = song.title,
            style = typography.s.copy(color = colorPalette.text),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = 8.dp)
        )

        song.artistsText?.takeIf { it.isNotBlank() }?.let { artists ->
            BasicText(
                text = artists,
                style = typography.xs.copy(color = colorPalette.textSecondary),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = 2.dp)
            )
        }
    }
}

@Composable
private fun HomeAlbumRow(
    albums: List<HomeAlbum>,
    onAlbumClick: (HomeAlbum) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(horizontal = 2.dp)
    ) {
        items(albums, key = { it.id }) { album ->
            HomeAlbumCard(
                album = album,
                onClick = { onAlbumClick(album) }
            )
        }
    }
}

@Composable
private fun HomeAlbumCard(
    album: HomeAlbum,
    onClick: () -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val artworkShape = RoundedCornerShape(8.dp)

    Column(
        modifier = Modifier
            .width(140.dp)
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(artworkShape)
                .background(colorPalette.background1)
        ) {
            val imageModel = album.imageUrl?.thumbnail(Dimensions.thumbnails.album.px)
            if (imageModel != null) {
                AsyncImage(
                    model = imageModel,
                    contentDescription = album.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
        }

        BasicText(
            text = album.title,
            style = typography.s.copy(color = colorPalette.text),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = 8.dp)
        )

        album.subtitle?.takeIf { it.isNotBlank() }?.let { subtitle ->
            BasicText(
                text = subtitle,
                style = typography.xs.copy(color = colorPalette.textSecondary),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = 2.dp)
            )
        }
    }
}

@Composable
private fun HomePlaylistRow(
    playlists: List<HomePlaylist>,
    onPlaylistClick: (HomePlaylist) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(horizontal = 2.dp)
    ) {
        items(playlists, key = { it.id }) { playlist ->
            HomePlaylistCard(
                playlist = playlist,
                onClick = { onPlaylistClick(playlist) }
            )
        }
    }
}

@Composable
private fun HomePlaylistCard(
    playlist: HomePlaylist,
    onClick: () -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current
    val artworkShape = RoundedCornerShape(8.dp)

    Column(
        modifier = Modifier
            .width(140.dp)
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(artworkShape)
                .background(colorPalette.background1)
        ) {
            val imageModel = playlist.imageUrl?.thumbnail(Dimensions.thumbnails.playlist.px)
            if (imageModel != null) {
                AsyncImage(
                    model = imageModel,
                    contentDescription = playlist.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
        }

        BasicText(
            text = playlist.title,
            style = typography.s.copy(color = colorPalette.text),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = 8.dp)
        )

        playlist.subtitle?.takeIf { it.isNotBlank() }?.let { subtitle ->
            BasicText(
                text = subtitle,
                style = typography.xs.copy(color = colorPalette.textSecondary),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = 2.dp)
            )
        }
    }
}

@Composable
private fun HomeArtistRow(
    artists: List<HomeArtist>,
    onArtistClick: (HomeArtist) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        contentPadding = PaddingValues(horizontal = 2.dp)
    ) {
        items(artists, key = { it.id }) { artist ->
            HomeArtistCard(
                artist = artist,
                onClick = { onArtistClick(artist) }
            )
        }
    }
}

@Composable
private fun HomeArtistCard(
    artist: HomeArtist,
    onClick: () -> Unit
) {
    val (colorPalette, typography) = LocalAppearance.current

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .width(100.dp)
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .size(100.dp)
                .clip(CircleShape)
                .background(colorPalette.background1)
        ) {
            val imageModel = artist.imageUrl?.thumbnail(Dimensions.thumbnails.artist.px)
            if (imageModel != null) {
                AsyncImage(
                    model = imageModel,
                    contentDescription = artist.name,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }
        }

        BasicText(
            text = artist.name,
            style = typography.xs.copy(color = colorPalette.text),
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = 8.dp)
        )
    }
}

@Composable
private fun HomeSectionInlinePlaceholder(endPadding: PaddingValues) {
    val (colorPalette) = LocalAppearance.current
    val layoutDirection = LocalLayoutDirection.current
    val insetEnd = endPadding.calculateEndPadding(layoutDirection)

    ShimmerHost {
        Row(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp)
                .padding(end = insetEnd)
        ) {
            repeat(3) {
                Column {
                    Box(
                        modifier = Modifier
                            .width(140.dp)
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(8.dp))
                            .background(colorPalette.background1)
                    )
                    Box(
                        modifier = Modifier
                            .padding(top = 8.dp)
                            .width(100.dp)
                            .height(12.dp)
                            .clip(RoundedCornerShape(4.dp))
                            .background(colorPalette.background1)
                    )
                }
            }
        }
    }
}

@Composable
private fun HomeSectionsPlaceholder(endPadding: PaddingValues) {
    val (colorPalette) = LocalAppearance.current
    val layoutDirection = LocalLayoutDirection.current
    val insetEnd = endPadding.calculateEndPadding(layoutDirection)

    ShimmerHost {
        repeat(3) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .padding(end = insetEnd)
            ) {
                Box(
                    modifier = Modifier
                        .width(120.dp)
                        .height(14.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(colorPalette.background1)
                )

                Spacer(modifier = Modifier.height(12.dp))

                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    repeat(3) {
                        Column {
                            Box(
                                modifier = Modifier
                                    .width(140.dp)
                                    .aspectRatio(1f)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(colorPalette.background1)
                            )
                            Box(
                                modifier = Modifier
                                    .padding(top = 8.dp)
                                    .width(100.dp)
                                    .height(12.dp)
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(colorPalette.background1)
                            )
                            Box(
                                modifier = Modifier
                                    .padding(top = 4.dp)
                                    .width(70.dp)
                                    .height(10.dp)
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(colorPalette.background2)
                            )
                        }
                    }
                }
            }
        }
    }
}

private data class HomeSectionSlice(
    val id: String,
    val title: String?,
    @StringRes val suffixRes: Int?,
    val type: HomeSectionSliceType,
    val songs: List<Song> = emptyList(),
    val albums: List<HomeAlbum> = emptyList(),
    val playlists: List<HomePlaylist> = emptyList(),
    val artists: List<HomeArtist> = emptyList(),
    val sectionIndex: Int,
    val localIndex: Int
)

private enum class HomeSectionSliceType(val sortOrder: Int) {
    Songs(0),
    Playlists(1),
    Albums(2),
    Artists(3)
}

private fun List<HomeSectionSlice>.sortedByTypeAndSection(): List<HomeSectionSlice> =
    this.sortedWith(compareBy({ it.type.sortOrder }, { it.sectionIndex }, { it.localIndex }))

private data class HomeAlbum(
    val id: String,
    val params: String?,
    val title: String,
    val subtitle: String?,
    val imageUrl: String?
)

private data class HomePlaylist(
    val id: String,
    val params: String?,
    val title: String,
    val subtitle: String?,
    val imageUrl: String?
)

private data class HomeArtist(
    val id: String,
    val name: String,
    val imageUrl: String?
)

private fun HomeSection.toSlices(sectionIndex: Int): List<HomeSectionSlice> {
        val songs = mutableListOf<Song>()
        val albums = mutableListOf<HomeAlbum>()
        val playlists = mutableListOf<HomePlaylist>()
        val artists = mutableListOf<HomeArtist>()
        val seenSongIds = LinkedHashSet<String>()
        val seenAlbumIds = LinkedHashSet<String>()
        val seenPlaylistIds = LinkedHashSet<String>()
        val seenArtistIds = LinkedHashSet<String>()

    items.forEach { item ->
        when {
                !item.videoId.isNullOrBlank() -> item.toSong()?.let { song ->
                    if (seenSongIds.add(song.id)) songs += song
                }

                item.isAlbumItem() -> item.toHomeAlbum()?.let { album ->
                    if (seenAlbumIds.add(album.id)) albums += album
                }

                !item.playlistId.isNullOrBlank() -> item.toHomePlaylist()?.let { playlist ->
                    if (seenPlaylistIds.add(playlist.id)) playlists += playlist
                }

                !item.browseId.isNullOrBlank() -> item.toHomeArtist()?.let { artist ->
                    if (seenArtistIds.add(artist.id)) artists += artist
                }
        }
    }

    if (songs.isEmpty() && albums.isEmpty() && playlists.isEmpty() && artists.isEmpty()) return emptyList()

    val sliceCount = listOf(songs, albums, playlists, artists).count { it.isNotEmpty() }
    val baseKey = (key ?: title ?: "section").ifBlank { "section" }
    val showSuffix = sliceCount > 1
    val slices = mutableListOf<HomeSectionSlice>()
    var localIndex = 0

    if (songs.isNotEmpty()) {
        slices += HomeSectionSlice(
            id = "$baseKey-songs-$localIndex",
            title = title,
            suffixRes = if (showSuffix) R.string.songs else null,
            type = HomeSectionSliceType.Songs,
            songs = songs,
            sectionIndex = sectionIndex,
            localIndex = localIndex
        )
        localIndex++
    }

    if (playlists.isNotEmpty()) {
        slices += HomeSectionSlice(
            id = "$baseKey-playlists-$localIndex",
            title = title,
            suffixRes = if (showSuffix) R.string.playlists else null,
            type = HomeSectionSliceType.Playlists,
            playlists = playlists,
            sectionIndex = sectionIndex,
            localIndex = localIndex
        )
        localIndex++
    }

    if (albums.isNotEmpty()) {
        slices += HomeSectionSlice(
            id = "$baseKey-albums-$localIndex",
            title = title,
            suffixRes = if (showSuffix) R.string.albums else null,
            type = HomeSectionSliceType.Albums,
            albums = albums,
            sectionIndex = sectionIndex,
            localIndex = localIndex
        )
        localIndex++
    }

    if (artists.isNotEmpty()) {
        slices += HomeSectionSlice(
            id = "$baseKey-artists-$localIndex",
            title = title,
            suffixRes = if (showSuffix) R.string.artists else null,
            type = HomeSectionSliceType.Artists,
            artists = artists,
            sectionIndex = sectionIndex,
            localIndex = localIndex
        )
    }

    return slices
}

private fun HomeItem.toHomePlaylist(): HomePlaylist? {
    val id = playlistId?.takeIf { it.isNotBlank() } ?: return null
    if (id.isAlbumPlaylistId()) return null
    val titleValue = name.trim()
    if (titleValue.isEmpty()) return null
    return HomePlaylist(
        id = id,
        params = params,
        title = titleValue,
        subtitle = author?.trim()?.takeIf { it.isNotEmpty() },
        imageUrl = image
    )
}

private fun HomeItem.toHomeAlbum(): HomeAlbum? {
    val id = playlistId?.takeIf { it.isNotBlank() } ?: return null
    if (!id.isAlbumPlaylistId()) return null
    val titleValue = name.trim()
    if (titleValue.isEmpty()) return null
    return HomeAlbum(
        id = id,
        params = params,
        title = titleValue,
        subtitle = author?.trim()?.takeIf { it.isNotEmpty() },
        imageUrl = image
    )
}

private fun HomeItem.toHomeArtist(): HomeArtist? {
    val id = browseId?.takeIf { it.isNotBlank() } ?: return null
    val titleValue = name.trim()
    if (titleValue.isEmpty()) return null
    return HomeArtist(
        id = id,
        name = titleValue,
        imageUrl = image
    )
}

private fun HomeItem.isAlbumItem(): Boolean = playlistId.isAlbumPlaylistId()

private fun String?.isAlbumPlaylistId(): Boolean =
    this?.startsWith("MPRE", ignoreCase = true) == true

private fun HomeItem.toSong(): Song? {
    val id = videoId?.takeIf { it.isNotBlank() } ?: return null
    val titleValue = name.trim()
    if (titleValue.isEmpty()) return null
    val artists = author?.trim()?.takeIf { it.isNotEmpty() }
    return Song(
        id = id,
        title = titleValue,
        artistsText = artists,
        durationText = null,
        thumbnailUrl = image,
        explicit = false
    )
}
