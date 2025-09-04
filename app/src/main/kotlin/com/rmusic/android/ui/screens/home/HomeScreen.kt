package com.rmusic.android.ui.screens.home

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.zIndex
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.animation.animateColorAsState
import com.rmusic.android.R
import com.rmusic.android.models.toUiMood
import com.rmusic.android.preferences.UIStatePreferences
// import com.rmusic.android.ui.components.themed.Scaffold (removed – replaced by bottom nav design)
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.screens.builtInPlaylistRoute
import com.rmusic.android.ui.screens.downloadedAlbumRoute
import com.rmusic.android.ui.screens.downloadedArtistRoute
import com.rmusic.android.ui.screens.builtinplaylist.BuiltInPlaylistScreen
import com.rmusic.android.ui.screens.localPlaylistRoute
import com.rmusic.android.ui.screens.localplaylist.LocalPlaylistScreen
import com.rmusic.android.ui.screens.mood.MoodScreen
import com.rmusic.android.ui.screens.mood.MoreAlbumsScreen
import com.rmusic.android.ui.screens.mood.MoreMoodsScreen
import com.rmusic.android.ui.screens.moodRoute
import com.rmusic.android.ui.screens.pipedPlaylistRoute
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.ui.screens.searchResultRoute
import com.rmusic.android.ui.screens.settingsRoute
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.Database
import com.rmusic.android.handleUrl
import androidx.core.net.toUri
import com.rmusic.android.models.SearchQuery
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.query
import com.rmusic.android.utils.toast
import com.rmusic.core.data.enums.BuiltInPlaylist
import com.rmusic.android.ui.screens.builtinplaylist.BuiltInPlaylistSongs
// removed duplicate R import
import com.rmusic.android.ui.screens.search.SearchScreen
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.Dimensions
import androidx.compose.ui.platform.LocalDensity
import com.rmusic.compose.persist.PersistMapCleanup
import androidx.media3.common.Player
import androidx.media3.common.MediaItem
import androidx.compose.runtime.DisposableEffect
import com.rmusic.compose.routing.Route0
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.providers.ytmusic.YTMusicProvider

private val moreMoodsRoute = Route0("moreMoodsRoute")
private val moreAlbumsRoute = Route0("moreAlbumsRoute")

@Route
@Composable
fun HomeScreen() {
    val saveableStateHolder = rememberSaveableStateHolder()

    PersistMapCleanup("home/")

    RouteHandler {
        GlobalRoutes()

        localPlaylistRoute { playlistId ->
            LocalPlaylistScreen(playlistId = playlistId)
        }

        builtInPlaylistRoute { builtInPlaylist ->
            BuiltInPlaylistScreen(builtInPlaylist = builtInPlaylist)
        }

        moodRoute { mood ->
            MoodScreen(mood = mood)
        }

        moreMoodsRoute {
            MoreMoodsScreen()
        }

        moreAlbumsRoute {
            MoreAlbumsScreen()
        }

        Content {
            var avatarUrl by remember { mutableStateOf<String?>(null) }
            LaunchedEffect(Unit) {
                val provider = YTMusicProvider.shared()
                provider.getAuthStateFlow().collect { state ->
                    if (state.isLoggedIn) {
                        avatarUrl = provider.getAvatarUrl(size = 88)
                    } else {
                        avatarUrl = null
                    }
                }
            }

            // Bottom navigation redesign (Inicio, Buscar, Biblioteca, Historial)
            val binder = LocalPlayerServiceBinder.current
            var hasMedia by remember(binder) { mutableStateOf(binder?.player?.currentMediaItem != null) }
            LaunchedEffect(binder) { hasMedia = binder?.player?.currentMediaItem != null }
            DisposableEffect(binder) {
                val player = binder?.player
                if (player == null) onDispose { } else {
                    val listener = object : Player.Listener {
                        override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
                            hasMedia = mediaItem != null
                        }
                    }
                    player.addListener(listener)
                    onDispose { player.removeListener(listener) }
                }
            }
            val (colorPalette, typography) = LocalAppearance.current
            var selectedIndex by remember { mutableStateOf(0) }
            var libraryTabIndex by remember { mutableStateOf(0) } // 0 Songs, 1 Albums, 2 Artists

            val insetPadding = LocalPlayerAwareWindowInsets.current
                .only(WindowInsetsSides.Top + WindowInsetsSides.End)
                .asPaddingValues()

            Column(Modifier.fillMaxSize()) {
                // Top bar with settings + avatar
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(insetPadding)
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                ) {
                    androidx.compose.foundation.Image(
                        painter = painterResource(R.drawable.settings),
                        contentDescription = null,
                        colorFilter = ColorFilter.tint(colorPalette.textSecondary),
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape)
                            .clickable { settingsRoute() }
                            .padding(4.dp)
                    )
                    Spacer(Modifier.weight(1f))
                    avatarUrl?.let { url ->
                        AsyncImage(
                            model = url,
                            contentDescription = null,
                            modifier = Modifier
                                .clip(CircleShape)
                                .size(44.dp)
                        )
                    }
                }

                // Content area (Spacer inserted later will lift navigation when media present)
                Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
                    val onSearchClick = { selectedIndex = 1 }
                    when (selectedIndex) {
                        0 -> saveableStateHolder.SaveableStateProvider(key = "home_quick_picks") {
                            QuickPicks(
                                onAlbumClick = { albumRoute(it.key) },
                                onArtistClick = { artistRoute(it.key) },
                                onPlaylistClick = {
                                    playlistRoute(
                                        p0 = it.key,
                                        p1 = null,
                                        p2 = null,
                                        p3 = it.channel?.name == "YouTube Music"
                                    )
                                },
                                onSearchClick = onSearchClick
                            )
                        }
            1 -> saveableStateHolder.SaveableStateProvider(key = "search_screen") {
                            // Inline SearchScreen replicating GlobalRoutes logic
                            val context = androidx.compose.ui.platform.LocalContext.current
                            SearchScreen(
                                initialTextInput = "",
                                onSearch = { query ->
                                    searchResultRoute(query)
                                    if (!DataPreferences.pauseSearchHistory) query {
                                        Database.insert(SearchQuery(query = query))
                                    }
                                },
                                onViewPlaylist = { url ->
                                    with(context) {
                                        runCatching { handleUrl(url.toUri(), binder) }
                                            .onFailure { toast(getString(R.string.error_url, url)) }
                                    }
                },
                onBack = { selectedIndex = 0 },
                autoFocusSearchInput = false
                            )
                        }
                        2 -> saveableStateHolder.SaveableStateProvider(key = "library") {
                            Column(Modifier.fillMaxSize()) {
                                // Library internal tabs (Songs / Albums / Artists)
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 12.dp, vertical = 4.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    @Composable
                                    fun libTab(label: Int, idx: Int) {
                                        val selected = libraryTabIndex == idx
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier
                                                .padding(end = 8.dp)
                                                .clip(RoundedCornerShape(20.dp))
                                                .background(if (selected) colorPalette.background2 else colorPalette.background1)
                                                .clickable { libraryTabIndex = idx }
                                                .padding(horizontal = 14.dp, vertical = 8.dp)
                                        ) {
                                            androidx.compose.foundation.Image(
                                                painter = painterResource(
                                                    when (idx) {
                                                        0 -> R.drawable.musical_notes
                                                        1 -> R.drawable.disc
                                                        else -> R.drawable.person
                                                    }
                                                ),
                                                contentDescription = null,
                                                colorFilter = ColorFilter.tint(colorPalette.text)
                                            )
                                            Spacer(Modifier.width(6.dp))
                                            androidx.compose.foundation.text.BasicText(
                                                text = stringResource(label),
                                                style = typography.xs
                                            )
                                        }
                                    }
                                    libTab(R.string.songs, 0)
                                    libTab(R.string.albums, 1)
                                    libTab(R.string.artists, 2)
                                }
                                Box(Modifier.fillMaxSize()) {
                                    when (libraryTabIndex) {
                                        0 -> HomeSongs(onSearchClick = onSearchClick)
                                        1 -> HomeAlbums(
                                            onAlbumClick = { downloadedAlbumRoute(it.id) },
                                            onSearchClick = onSearchClick
                                        )
                                        2 -> HomeArtistList(
                                            onArtistClick = { downloadedArtistRoute(it.id) },
                                            onSearchClick = onSearchClick
                                        )
                                    }
                                }
                            }
                        }
                        3 -> saveableStateHolder.SaveableStateProvider(key = "history") {
                            BuiltInPlaylistSongs(builtInPlaylist = BuiltInPlaylist.History)
                        }
                    }
                }

        // Bottom Navigation Bar (offset upward if mini player is showing)
                val density = LocalDensity.current
                val navBarBottomInset = with(density) { WindowInsets.navigationBars.getBottom(density).toDp() }
        val navOffset = if (hasMedia) -Dimensions.items.collapsedPlayerHeight else 0.dp
        val navBarColor = colorPalette.background0
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .offset(y = navOffset)
                .background(navBarColor)
                .zIndex(2f)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(Dimensions.items.bottomNavigationHeight)
                    .padding(horizontal = 4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                    @Composable
                    fun navItem(index: Int, icon: Int, label: Int) {
                        val selected = selectedIndex == index
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            modifier = Modifier
                                .weight(1f)
                                .fillMaxHeight()
                                .background(if (selected) colorPalette.background2 else Color.Transparent)
                                .clickable { selectedIndex = index }
                                .padding(vertical = 6.dp)
                        ) {
                            androidx.compose.foundation.Image(
                                painter = painterResource(icon),
                                contentDescription = null,
                                colorFilter = ColorFilter.tint(if (selected) colorPalette.text else colorPalette.textSecondary)
                            )
                            androidx.compose.foundation.text.BasicText(
                                text = stringResource(label),
                                style = typography.xs.copy(color = if (selected) colorPalette.text else colorPalette.textSecondary),
                                modifier = Modifier.padding(top = 2.dp)
                            )
                        }
                        }
                        navItem(0, R.drawable.sparkles, R.string.inicio)
                        navItem(1, R.drawable.search, R.string.search)
                        navItem(2, R.drawable.library, R.string.library)
                        navItem(3, R.drawable.history, R.string.history)
                    }
                }
                // Spacer only for system navigation bar inset; collapsed player offset handled globally.
                Spacer(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(navBarBottomInset)
                )
            }
        }
    }
}
