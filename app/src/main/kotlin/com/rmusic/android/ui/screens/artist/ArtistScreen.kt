package com.rmusic.android.ui.screens.artist

import android.content.Intent
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.saveable.rememberSaveableStateHolder
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.rmusic.android.Database
import com.rmusic.android.R
import com.rmusic.android.models.Artist
import com.rmusic.android.preferences.UIStatePreferences
import com.rmusic.android.query
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderIconButton
import com.rmusic.android.ui.components.themed.HeaderPlaceholder
import com.rmusic.android.ui.components.themed.Scaffold
import com.rmusic.android.ui.components.themed.adaptiveThumbnailContent
import com.rmusic.android.ui.screens.GlobalRoutes
import com.rmusic.android.ui.screens.Route
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.compose.persist.PersistMapCleanup
import com.rmusic.compose.persist.persist
import com.rmusic.compose.routing.RouteHandler
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.intermusic.pages.ArtistResult
import com.valentinilk.shimmer.shimmer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.withContext

@Route
@Composable
fun ArtistScreen(browseId: String) {

    val saveableStateHolder = rememberSaveableStateHolder()

    PersistMapCleanup(prefix = "artist/$browseId/")

    var artist by persist<Artist?>("artist/$browseId/artist")

    var artistPage by persist<ArtistResult?>("artist/$browseId/artistPage")

    LaunchedEffect(Unit) {
        Database
            .artist(browseId)
            .distinctUntilChanged()
            .collect { currentArtist ->
                artist = currentArtist

                if (artistPage == null || currentArtist?.timestamp == null) {
                    withContext(Dispatchers.IO) {
                        IntermusicProvider.shared()
                            .getArtist(browseId)
                            .onSuccess { currentArtistPage ->
                                artistPage = currentArtistPage

                                Database.upsert(
                                    Artist(
                                        id = browseId,
                                        name = currentArtistPage.name,
                                        thumbnailUrl = currentArtistPage.thumbnails.firstOrNull()?.url,
                                        timestamp = System.currentTimeMillis(),
                                        bookmarkedAt = currentArtist?.bookmarkedAt
                                    )
                                )
                            }
                            .onFailure { it.printStackTrace() }
                    }
                }
            }
    }

    RouteHandler {
        GlobalRoutes()

        Content {
            val thumbnailContent = adaptiveThumbnailContent(
                isLoading = artist?.timestamp == null,
                url = artist?.thumbnailUrl,
                shape = CircleShape
            )

            val headerContent: @Composable (textButton: (@Composable () -> Unit)?) -> Unit =
                { textButton ->
                    if (artist?.timestamp == null) HeaderPlaceholder(
                        modifier = Modifier.shimmer()
                    ) else {
                        val (colorPalette) = LocalAppearance.current
                        val context = LocalContext.current

                        Header(title = artist?.name ?: stringResource(R.string.unknown)) {
                            textButton?.invoke()

                            Spacer(modifier = Modifier.weight(1f))

                            HeaderIconButton(
                                icon = if (artist?.bookmarkedAt == null) R.drawable.bookmark_outline
                                else R.drawable.bookmark,
                                color = colorPalette.accent,
                                onClick = {
                                    val bookmarkedAt = if (artist?.bookmarkedAt == null)
                                        System.currentTimeMillis() else null

                                    query {
                                        artist
                                            ?.copy(bookmarkedAt = bookmarkedAt)
                                            ?.let(Database::update)
                                    }
                                }
                            )

                            HeaderIconButton(
                                icon = R.drawable.share_social,
                                color = colorPalette.text,
                                onClick = {
                                    val sendIntent = Intent().apply {
                                        action = Intent.ACTION_SEND
                                        type = "text/plain"
                                        putExtra(
                                            Intent.EXTRA_TEXT,
                                            "https://music.youtube.com/channel/$browseId"
                                        )
                                    }

                                    context.startActivity(Intent.createChooser(sendIntent, null))
                                }
                            )
                        }
                    }
                }

            Scaffold(
                key = "artist",
                topIconButtonId = R.drawable.chevron_back,
                onTopIconButtonClick = pop,
                tabIndex = UIStatePreferences.artistScreenTabIndex.coerceAtMost(1),
                onTabChange = { newIndex -> UIStatePreferences.artistScreenTabIndex = newIndex.coerceAtMost(1) },
                tabColumnContent = {
                    tab(0, R.string.overview, R.drawable.sparkles)
                    tab(1, R.string.library, R.drawable.library)
                }
            ) { currentTabIndex ->
                val clampedIndex = currentTabIndex.coerceAtMost(1)
                saveableStateHolder.SaveableStateProvider(key = clampedIndex) {
                    when (clampedIndex) {
                        0 -> ArtistOverview(
                            artist = artistPage,
                            thumbnailContent = thumbnailContent,
                            headerContent = headerContent,
                            onAlbumClick = { albumRoute(it) },
                            onViewAllSongsClick = null,
                            onViewAllAlbumsClick = null,
                            onViewAllSinglesClick = null
                        )

                        else -> ArtistLocalSongs(
                            browseId = browseId,
                            headerContent = headerContent,
                            thumbnailContent = thumbnailContent
                        )
                    }
                }
            }
        }
    }
}
