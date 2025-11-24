package com.rmusic.android.ui.screens.mood

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.util.fastForEachIndexed
import com.rmusic.android.LocalPlayerAwareWindowInsets
import com.rmusic.android.R
import com.rmusic.android.ui.components.ShimmerHost
import com.rmusic.android.ui.components.themed.Header
import com.rmusic.android.ui.components.themed.HeaderPlaceholder
import com.rmusic.android.ui.items.ItemContainer
import com.rmusic.android.ui.items.SongItemPlaceholder
import com.rmusic.android.utils.center
import com.rmusic.android.utils.color
import com.rmusic.android.utils.semiBold
import com.rmusic.android.utils.thumbnail
import com.rmusic.compose.persist.persist
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.onOverlay
import com.rmusic.core.ui.overlay
import com.rmusic.core.ui.utils.px
import com.rmusic.core.ui.utils.roundedShape
import com.rmusic.providers.intermusic.IntermusicProvider
import com.valentinilk.shimmer.shimmer
import kotlinx.collections.immutable.toImmutableList

@Composable
fun MoreMoodsList(
    onMoodClick: (mood: IntermusicProvider.MoodItem) -> Unit,
    modifier: Modifier = Modifier,
    columns: Int = 2
) {
    val (colorPalette, typography) = LocalAppearance.current
    val windowInsets = LocalPlayerAwareWindowInsets.current

    val endPaddingValues = windowInsets.only(WindowInsetsSides.End).asPaddingValues()

    val sectionTextModifier = Modifier
        .padding(horizontal = 16.dp)
        .padding(top = 24.dp, bottom = 8.dp)
        .padding(endPaddingValues)

    var moodSections by persist<List<IntermusicProvider.MoodSection>?>(tag = "more_moods/list")
    var loadError by remember { mutableStateOf<Throwable?>(null) }

    val data by remember {
        derivedStateOf {
            moodSections?.map { section ->
                section.title to section.items.toImmutableList()
            }
        }
    }

    LaunchedEffect(Unit) {
        if (moodSections != null || loadError != null) return@LaunchedEffect

        val provider = IntermusicProvider.shared()
        val result = provider.getMoods()
        loadError = result.exceptionOrNull()
        moodSections = result.getOrNull()
    }

    LazyVerticalGrid(
        columns = GridCells.Fixed(columns),
        contentPadding = windowInsets
            .only(WindowInsetsSides.Vertical + WindowInsetsSides.End)
            .asPaddingValues(),
        modifier = modifier
            .background(colorPalette.background0)
            .fillMaxSize()
    ) {
        item(
            key = "header",
            contentType = 0,
            span = { GridItemSpan(columns) }
        ) {
            if (data == null && loadError == null) HeaderPlaceholder(modifier = Modifier.shimmer())
            else Header(
                title = stringResource(R.string.moods_and_genres),
                modifier = Modifier.padding(endPaddingValues)
            )
        }

        data?.let { page ->
            if (page.isNotEmpty()) page.fastForEachIndexed { i, (title, moods) ->
                item(
                    key = "header:$i,$title",
                    contentType = 0,
                    span = { GridItemSpan(columns) }
                ) {
                    BasicText(
                        text = title,
                        style = typography.m.semiBold,
                        modifier = sectionTextModifier
                    )
                }

                itemsIndexed(
                    items = moods,
                    key = { j, item -> "item:$j,${item.browseId ?: item.title}" }
                ) { _, mood ->
                    ItemContainer(
                        alternative = true,
                        thumbnailSize = Dimensions.thumbnails.album,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(4.dp)
                            .clickable {
                                if (mood.browseId != null) onMoodClick(mood)
                            }
                    ) { centeredModifier ->
                        val (colorPalette, typography, thumbnailShapeCorners) = LocalAppearance.current

                        Box(
                            modifier = centeredModifier
                                .clip(thumbnailShapeCorners.roundedShape)
                                .background(color = colorPalette.background1)
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .aspectRatio(1f)
                                    .background(androidx.compose.ui.graphics.Color(mood.stripeColor))
                            )

                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(colorPalette.overlay)
                            )

                            BasicText(
                                text = mood.title,
                                style = typography.m.semiBold.center.color(colorPalette.onOverlay),
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis,
                                modifier = Modifier
                                    .align(Alignment.Center)
                                    .padding(8.dp)
                            )
                        }
                    }
                }
            }
        }

        if (moodSections == null && loadError == null) item(
            key = "loading",
            contentType = 0,
            span = { GridItemSpan(columns) }
        ) {
            ShimmerHost(modifier = Modifier.fillMaxWidth()) {
                repeat(4) {
                    SongItemPlaceholder(thumbnailSize = Dimensions.thumbnails.song)
                }
            }
        }

        loadError?.let { error ->
            item(
                key = "error",
                contentType = 0,
                span = { GridItemSpan(columns) }
            ) {
                BasicText(
                    text = error.localizedMessage ?: stringResource(R.string.error_loading_content),
                    style = typography.m.semiBold,
                    modifier = Modifier
                        .padding(16.dp)
                        .padding(endPaddingValues)
                )
            }
        }
    }
}
