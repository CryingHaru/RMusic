package com.rmusic.android.preferences

import com.rmusic.android.models.Song
import com.rmusic.providers.intermusic.pages.HomeItem
import com.rmusic.providers.intermusic.pages.HomeSection
import kotlinx.serialization.Serializable

@Serializable
data class CachedSongSummary(
    val id: String,
    val title: String,
    val artistsText: String? = null,
    val durationText: String? = null,
    val thumbnailUrl: String? = null,
    val explicit: Boolean = false
)

@Serializable
data class QuickPicksSnapshot(
    val items: List<CachedSongSummary> = emptyList(),
    @Deprecated("Use items instead")
    val trending: CachedSongSummary? = null,
    val timestamp: Long = 0L,
    val sections: List<CachedHomeSection> = emptyList(),
    val continuationToken: String? = null
)

fun QuickPicksSnapshot.hasContent(): Boolean =
    sections.isNotEmpty() || resolvedItems().isNotEmpty()

fun QuickPicksSnapshot.hasSections(): Boolean = sections.isNotEmpty()

fun QuickPicksSnapshot.resolvedItems(): List<CachedSongSummary> =
    if (items.isNotEmpty()) items else trending?.let(::listOf) ?: emptyList()

fun QuickPicksSnapshot.toSongs(): List<Song> = resolvedItems().map(CachedSongSummary::toSong)

fun QuickPicksSnapshot.toHomeSections(): List<HomeSection> = sections.toHomeSections()

fun Song.toSnapshot(): CachedSongSummary = CachedSongSummary(
    id = id,
    title = title,
    artistsText = artistsText,
    durationText = durationText,
    thumbnailUrl = thumbnailUrl,
    explicit = explicit
)

fun CachedSongSummary.toSong(): Song = Song(
    id = id,
    title = title,
    artistsText = artistsText,
    durationText = durationText,
    thumbnailUrl = thumbnailUrl,
    explicit = explicit
)

fun List<Song>.toSnapshots(): List<CachedSongSummary> = map(Song::toSnapshot)

@Serializable
data class CachedHomeSection(
    val key: String? = null,
    val title: String? = null,
    val items: List<CachedHomeItem> = emptyList()
)

@Serializable
data class CachedHomeItem(
    val name: String,
    val author: String? = null,
    val videoId: String? = null,
    val playlistId: String? = null,
    val browseId: String? = null,
    val image: String? = null,
    val params: String? = null
)

fun List<HomeSection>.toCachedSections(): List<CachedHomeSection> = map(HomeSection::toCached)

fun List<CachedHomeSection>.toHomeSections(): List<HomeSection> = map(CachedHomeSection::toHomeSection)

fun HomeSection.toCached(): CachedHomeSection = CachedHomeSection(
    key = key,
    title = title,
    items = items.map(HomeItem::toCached)
)

fun CachedHomeSection.toHomeSection(): HomeSection = HomeSection(
    key = key,
    title = title,
    items = items.map(CachedHomeItem::toHomeItem)
)

fun HomeItem.toCached(): CachedHomeItem = CachedHomeItem(
    name = name,
    author = author,
    videoId = videoId,
    playlistId = playlistId,
    browseId = browseId,
    image = image,
    params = params
)

fun CachedHomeItem.toHomeItem(): HomeItem = HomeItem(
    name = name,
    author = author,
    videoId = videoId,
    playlistId = playlistId,
    browseId = browseId,
    image = image,
    params = params
)
