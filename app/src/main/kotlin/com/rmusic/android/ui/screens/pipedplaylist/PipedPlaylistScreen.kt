package com.rmusic.android.ui.screens.pipedplaylist

import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import com.rmusic.android.R
import com.rmusic.android.ui.components.themed.Scaffold
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.providers.piped.models.authenticatedWith
import io.ktor.http.Url
import java.util.UUID

@Route
@Composable
fun PipedPlaylistScreen(
    apiBaseUrl: Url,
    sessionToken: String,
    playlistId: UUID
) {
    val saveableStateHolder = rememberSaveableStateHolder()
    val session by remember { derivedStateOf { apiBaseUrl authenticatedWith sessionToken } }

    PersistMapCleanup(prefix = "pipedplaylist/$playlistId")

    RouteHandler {
        GlobalRoutes()

        Content {
            Scaffold(
                key = "pipedplaylist",
                topIconButtonId = R.drawable.chevron_back,
                onTopIconButtonClick = pop,
                tabIndex = 0,
                onTabChange = { },
                tabColumnContent = {
                    tab(0, R.string.songs, R.drawable.musical_notes)
                }
            ) { currentTabIndex ->
                saveableStateHolder.SaveableStateProvider(key = currentTabIndex) {
                    when (currentTabIndex) {
                        0 -> PipedPlaylistSongList(
                            session = session,
                            playlistId = playlistId
                        )
                    }
                }
            }
        }
    }
}
