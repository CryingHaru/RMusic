package com.rmusic.android.ui.screens.search

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextAlign
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.models.DownloadedSong
import com.rmusic.android.ui.components.LocalMenuState
import com.rmusic.android.ui.components.themed.FloatingActionsContainerWithScrollToTop
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.InHistoryMediaItemMenu
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.items.SongItem
import com.rmusic.android.utils.align
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.forcePlay
import com.rmusic.android.utils.medium
import com.rmusic.android.utils.playingSong
import com.rmusic.compose.persist.persistList
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.providers.innertube.models.NavigationEndpoint
import kotlinx.collections.immutable.toImmutableList

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun DownloadedSongSearch(
    textFieldValue: TextFieldValue,
    onTextFieldValueChange: (TextFieldValue) -> Unit,
    decorationBox: @Composable (@Composable () -> Unit) -> Unit,
    modifier: Modifier = Modifier
) {
    val (colorPalette, typography) = LocalAppearance.current
    val binder = LocalPlayerServiceBinder.current
    val menuState = LocalMenuState.current

    val allDownloadedSongs by Database.downloadedSongs().collectAsState(initial = emptyList())
    var filteredItems by remember { mutableStateOf<List<DownloadedSong>>(emptyList()) }

    LaunchedEffect(textFieldValue.text, allDownloadedSongs) {
        filteredItems = if (textFieldValue.text.length > 1) {
            allDownloadedSongs.filter { song ->
                song.title.contains(textFieldValue.text, ignoreCase = true) ||
                song.artistsText?.contains(textFieldValue.text, ignoreCase = true) == true ||
                song.albumTitle?.contains(textFieldValue.text, ignoreCase = true) == true
            }
        } else {
            allDownloadedSongs
        }
    }

    val lazyListState = rememberLazyListState()
    val (currentMediaId, playing) = playingSong(binder)

    Box(modifier = modifier) {
        LazyColumn(
            state = lazyListState,
            contentPadding = LocalPlayerAwareWindowInsets.current
                .only(WindowInsetsSides.Vertical + WindowInsetsSides.End).asPaddingValues(),
            modifier = Modifier.fillMaxSize()
        ) {
            item(
                key = "header",
                contentType = 0
            ) {
                Header(
                    titleContent = {
                        BasicTextField(
                            value = textFieldValue,
                            onValueChange = onTextFieldValueChange,
                            textStyle = typography.xxl.medium.align(TextAlign.End),
                            singleLine = true,
                            maxLines = 1,
                            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                            cursorBrush = SolidColor(colorPalette.text),
                            decorationBox = decorationBox
                        )
                    },
                    actionsContent = {
                        if (textFieldValue.text.isNotEmpty()) SecondaryTextButton(
                            text = stringResource(R.string.clear),
                            onClick = { onTextFieldValueChange(TextFieldValue()) }
                        )
                    }
                )
            }

            items(
                items = filteredItems,
                key = DownloadedSong::id
            ) { downloadedSong ->
                val song = downloadedSong.toSong()
                SongItem(
                    modifier = Modifier
                        .combinedClickable(
                            onLongClick = {
                                menuState.display {
                                    InHistoryMediaItemMenu(
                                        song = song,
                                        onDismiss = menuState::hide
                                    )
                                }
                            },
                            onClick = {
                                val mediaItem = song.asMediaItem
                                binder?.stopRadio()
                                binder?.player?.forcePlay(mediaItem)
                                binder?.setupRadio(
                                    NavigationEndpoint.Endpoint.Watch(videoId = mediaItem.mediaId)
                                )
                            }
                        )
                        .animateItem(),
                    song = song,
                    thumbnailSize = Dimensions.thumbnails.song,
                    isPlaying = playing && currentMediaId == song.id
                )
            }
        }

        FloatingActionsContainerWithScrollToTop(lazyListState = lazyListState)
    }
}
