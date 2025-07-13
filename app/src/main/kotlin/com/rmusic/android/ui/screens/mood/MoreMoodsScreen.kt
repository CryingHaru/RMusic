package com.rmusic.android.ui.screens.mood

import androidx.compose.runtime.Composable
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import com.rmusic.android.R
import com.rmusic.android.models.toUiMood
import com.rmusic.android.ui.components.themed.Scaffold
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.moodRoute
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.routing.RouteHandler

@Route
@Composable
fun MoreMoodsScreen() {
    val saveableStateHolder = rememberSaveableStateHolder()

    PersistMapCleanup(prefix = "more_moods/")

    RouteHandler {
        GlobalRoutes()

        moodRoute { mood ->
            MoodScreen(mood = mood)
        }

        Content {
            Scaffold(
                key = "moremoods",
                topIconButtonId = R.drawable.chevron_back,
                onTopIconButtonClick = pop,
                tabIndex = 0,
                onTabChange = { },
                tabColumnContent = {
                    tab(0, R.string.moods_and_genres, R.drawable.playlist)
                }
            ) { currentTabIndex ->
                saveableStateHolder.SaveableStateProvider(key = currentTabIndex) {
                    when (currentTabIndex) {
                        0 -> MoreMoodsList(
                            onMoodClick = { mood -> moodRoute(mood.toUiMood()) }
                        )
                    }
                }
            }
        }
    }
}
