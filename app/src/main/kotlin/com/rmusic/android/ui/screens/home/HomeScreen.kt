package com.rmusic.android.ui.screens.home

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.layout.onGloballyPositioned
import coil3.compose.AsyncImage
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import com.rmusic.android.R
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
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.ui.screens.searchResultRoute
import com.rmusic.android.ui.screens.settingsRoute
import com.rmusic.compose.routing.OnGlobalRoute
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
import com.rmusic.android.ui.screens.search.SearchScreen
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.Dimensions
import androidx.compose.ui.platform.LocalDensity
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.routing.Route0
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.providers.intermusic.IntermusicProvider

private val moreMoodsRoute = Route0("moreMoodsRoute")
private val moreAlbumsRoute = Route0("moreAlbumsRoute")

@Route
@Composable
fun HomeScreen(
    onBottomBarHeightChange: (Dp) -> Unit = {}
) {
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
            val provider = remember { IntermusicProvider.shared() }
            val authState by provider.getAuthStateFlow().collectAsState()
            var avatarUrl by remember { mutableStateOf<String?>(null) }

            LaunchedEffect(authState) {
                avatarUrl = if (authState.isLoggedIn) provider.getAvatarUrl(size = 88) else null
            }

            val binder = LocalPlayerServiceBinder.current
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
                            .clickable { settingsRoute.global() }
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

                // Content area
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                ) {
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
                                        .horizontalScroll(rememberScrollState())
                                        .padding(horizontal = 12.dp, vertical = 4.dp),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    @Composable
                                    fun libTab(label: Int, idx: Int) {
                                        val selected = libraryTabIndex == idx
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier
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
                                                style = typography.xs,
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
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

            // Bottom navigation bar (hidden on the settings screen)
            val density = LocalDensity.current
            val navBarBottomInset = with(density) { WindowInsets.navigationBars.getBottom(density).toDp() }
            val navBarColor = colorPalette.background0
            val navExtraGap = 6.dp
            var hideBottomBar by remember { mutableStateOf(false) }
            OnGlobalRoute { (route, _) ->
                hideBottomBar = route == settingsRoute
            }
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .onGloballyPositioned { coords ->
                        onBottomBarHeightChange(with(density) { coords.size.height.toDp() })
                    }
                    .height(Dimensions.items.bottomNavigationHeight + navExtraGap + navBarBottomInset)
                    .background(navBarColor)
                    .zIndex(3f)
                    .padding(bottom = navBarBottomInset)
            ) {
                if (!hideBottomBar) {
                    val navItems = listOf(
                        R.drawable.sparkles to R.string.inicio,
                        R.drawable.search to R.string.search,
                        R.drawable.library to R.string.library,
                        R.drawable.history to R.string.history
                    )

                    Row(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                            .height(Dimensions.items.bottomNavigationHeight)
                            .padding(horizontal = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        navItems.forEachIndexed { index, (icon, label) ->
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
                    }
                }
            }
        }
    }
}


}