package com.rmusic.android.ui.screens.home

import androidx.compose.runtime.Composable
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import com.rmusic.android.R
import com.rmusic.android.models.toUiMood
import com.rmusic.android.preferences.UIStatePreferences
import com.rmusic.android.ui.components.themed.Scaffold
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
import com.rmusic.android.ui.screens.searchRoute
import com.rmusic.android.ui.screens.settingsRoute
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.routing.Route0
import com.rmusic.compose.routing.RouteHandler

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
            Scaffold(
                key = "home",
                topIconButtonId = R.drawable.settings,
                onTopIconButtonClick = { settingsRoute() },
                tabIndex = UIStatePreferences.homeScreenTabIndex,
                onTabChange = { UIStatePreferences.homeScreenTabIndex = it },
                tabColumnContent = {
                    tab(0, R.string.quick_picks, R.drawable.sparkles)
                    tab(1, R.string.songs, R.drawable.musical_notes)
                    tab(2, R.string.albums, R.drawable.disc)
                    tab(3, R.string.artists, R.drawable.person)
                    tab(4, R.string.history, R.drawable.history)
                    tab(5, R.string.downloads, R.drawable.download)
                }
            ) { currentTabIndex ->
                saveableStateHolder.SaveableStateProvider(key = currentTabIndex) {
                    val onSearchClick = { searchRoute("") }
                    when (currentTabIndex) {
                        0 -> QuickPicks(
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

                        1 -> HomeSongs(
                            onSearchClick = onSearchClick
                        )

                        2 -> HomeAlbums(
                            onAlbumClick = { downloadedAlbumRoute(it.id) },
                            onSearchClick = onSearchClick
                        )

                        3 -> HomeArtistList(
                            onArtistClick = { downloadedArtistRoute(it.id) },
                            onSearchClick = onSearchClick
                        )

                        4 -> HomePlaylists(
                            onBuiltInPlaylist = { builtInPlaylistRoute(it) },
                            onPlaylistClick = { localPlaylistRoute(it.id) },
                            onPipedPlaylistClick = { session, playlist ->
                                pipedPlaylistRoute(
                                    p0 = session.apiBaseUrl.toString(),
                                    p1 = session.token,
                                    p2 = playlist.id.toString()
                                )
                            },
                            onSearchClick = onSearchClick
                        )

                        5 -> HomeDownloads(
                            onSearchClick = onSearchClick,
                            onArtistClick = { downloadedArtistRoute(it) }
                        )
                    }
                }
            }
        }
    }
}
