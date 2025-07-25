package com.rmusic.providers.innertube.requests

import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.Innertube.toMood
import com.rmusic.providers.innertube.models.BrowseResponse
import com.rmusic.providers.innertube.models.GridRenderer
import com.rmusic.providers.innertube.models.MusicCarouselShelfRenderer
import com.rmusic.providers.innertube.models.MusicNavigationButtonRenderer
import com.rmusic.providers.innertube.models.MusicResponsiveListItemRenderer
import com.rmusic.providers.innertube.models.MusicTwoRowItemRenderer
import com.rmusic.providers.innertube.models.SectionListRenderer
import com.rmusic.providers.innertube.models.bodies.BrowseBody
import com.rmusic.providers.innertube.utils.from
import com.rmusic.providers.utils.runCatchingCancellable
import io.ktor.client.call.body
import io.ktor.client.request.post
import io.ktor.client.request.setBody

suspend fun Innertube.browse(body: BrowseBody) = runCatchingCancellable {
    val response = client.post(BROWSE) {
        setBody(body)
    }.body<BrowseResponse>()

    BrowseResult(
        title = response
            .header
            ?.musicImmersiveHeaderRenderer
            ?.title
            ?.text
            ?: response
                .header
                ?.musicDetailHeaderRenderer
                ?.title
                ?.text,
        items = response
            .contents
            ?.singleColumnBrowseResultsRenderer
            ?.tabs
            ?.firstOrNull()
            ?.tabRenderer
            ?.content
            ?.sectionListRenderer
            ?.toBrowseItems()
            .orEmpty()
    )
}

fun SectionListRenderer.toBrowseItems() = contents?.mapNotNull { content ->
    when {
        content.gridRenderer != null -> content.gridRenderer.toBrowseItem()
        content.musicCarouselShelfRenderer != null -> content.musicCarouselShelfRenderer.toBrowseItem()
        else -> null
    }
}

fun GridRenderer.toBrowseItem() = BrowseResult.Item(
    title = header
        ?.gridHeaderRenderer
        ?.title
        ?.runs
        ?.firstOrNull()
        ?.text,
    items = items
        ?.mapNotNull {
            it.musicTwoRowItemRenderer?.toItem() ?: it.musicNavigationButtonRenderer?.toItem()
        }
        .orEmpty()
)

fun MusicCarouselShelfRenderer.toBrowseItem(
    fromResponsiveListItemRenderer: ((MusicResponsiveListItemRenderer) -> Innertube.Item?)? = null
) = BrowseResult.Item(
    title = header
        ?.musicCarouselShelfBasicHeaderRenderer
        ?.title
        ?.runs
        ?.firstOrNull()
        ?.text,
    items = contents
        ?.mapNotNull {
            it.musicResponsiveListItemRenderer?.let { renderer ->
                fromResponsiveListItemRenderer?.invoke(renderer)
            } ?: it.musicTwoRowItemRenderer?.toItem()
                ?: it.musicNavigationButtonRenderer?.toItem()
        }
        .orEmpty()
)

data class BrowseResult(
    val title: String?,
    val items: List<Item>
) {
    data class Item(
        val title: String?,
        val items: List<Innertube.Item>
    )
}

fun MusicTwoRowItemRenderer.toItem() = when {
    isAlbum -> Innertube.AlbumItem.from(this)
    isPlaylist -> Innertube.PlaylistItem.from(this)
    isArtist -> Innertube.ArtistItem.from(this)
    else -> null
}

fun MusicNavigationButtonRenderer.toItem() = when {
    isMood -> toMood()
    else -> null
}
