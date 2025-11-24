package com.rmusic.providers.intermusic.parser

import com.rmusic.providers.intermusic.models.response.BrowseResponse
import com.rmusic.providers.intermusic.models.response.LibraryResponse
import com.rmusic.providers.intermusic.models.response.PlayerResponse
import com.rmusic.providers.intermusic.models.response.ResponseContext
import com.rmusic.providers.intermusic.models.response.SearchSuggestionsResponse
import com.rmusic.providers.intermusic.pages.AlbumItem
import com.rmusic.providers.intermusic.pages.AlbumResult
import com.rmusic.providers.intermusic.pages.ArtistItem
import com.rmusic.providers.intermusic.pages.ArtistResult
import com.rmusic.providers.intermusic.pages.AudioFormat
import com.rmusic.providers.intermusic.pages.HomeItem
import com.rmusic.providers.intermusic.pages.HomeResult
import com.rmusic.providers.intermusic.pages.HomeSection
import com.rmusic.providers.intermusic.pages.PlaylistItem
import com.rmusic.providers.intermusic.pages.PlaylistResult
import com.rmusic.providers.intermusic.pages.SearchResult
import com.rmusic.providers.intermusic.pages.SongItem
import com.rmusic.providers.intermusic.pages.SongResult
import com.rmusic.providers.intermusic.pages.StreamingData
import com.rmusic.providers.intermusic.pages.Thumbnail
import com.rmusic.providers.intermusic.pages.VideoItem
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.encodeToJsonElement
import java.text.Normalizer
import java.util.Locale

private val jsonFormatter = Json { ignoreUnknownKeys = true; encodeDefaults = false }
private val yearRegex = Regex("\\d{4}")
private val diacriticsRegex = "\\p{Mn}+".toRegex()

private enum class SearchShelfCategory { SONGS, ALBUMS, ARTISTS, VIDEOS, PLAYLISTS }

private val searchCategoryKeywords = mapOf(
    SearchShelfCategory.SONGS to setOf(
        "song", "songs", "track", "tracks", "cancion", "canciones", "musica", "musicas",
        "titulo", "titulos", "titolo", "titoli", "titre", "titres", "morceaux", "brano", "brani", "canzone",
        "canzoni", "lied", "lieder", "tema", "temas", "pista", "pistas", "musique",
        "faixa", "faixas", "곡", "노래", "曲", "歌曲", "歌", "曲目", "песня", "песни", "песен", "şarkı",
        "şarkilar", "şarkılar", "गीत", "गीतें", "গান", "cancoes", "canções", "titel"
    ),
    SearchShelfCategory.VIDEOS to setOf(
        "video", "videos", "vídeo", "vídeos", "vidéo", "vidéos", "ビデオ", "動画", "동영상",
        "видео", "videoclipe", "videoclipes", "영상"
    ),
    SearchShelfCategory.ALBUMS to setOf(
        "album", "albums", "álbum", "álbumes", "albumes", "álbuns", "albuns",
        "disco", "discos", "アルバム", "앨범", "альбом", "альбомы", "albüm"
    ),
    SearchShelfCategory.ARTISTS to setOf(
        "artist", "artists", "artista", "artistas", "artiste", "artistes", "artisti",
        "künstler", "interprete", "intérpretes", "아티스트", "アーティスト", "исполнитель",
        "исполнители", "sanatci", "sanatçılar", "कलाकार"
    ),
    SearchShelfCategory.PLAYLISTS to setOf(
        "playlist", "playlists", "lista de reproduccion", "listas de reproduccion",
        "lista de reproducción", "listas de reproducción", "lista", "listas", "재생목록",
        "プレイリスト", "плейлист", "плейлисты", "çalma listesi", "çalma listeleri"
    )
).mapValues { (_, keywords) -> keywords.map(String::normalizeSearchCategoryText).toSet() }

fun parseSearchResults(response: BrowseResponse): SearchResult {
    val songs = mutableListOf<SongItem>()
    val albums = mutableListOf<AlbumItem>()
    val artists = mutableListOf<ArtistItem>()
    val playlists = mutableListOf<PlaylistItem>()
    val videos = mutableListOf<VideoItem>()

    val sections = response.firstTabSections()
    sections.forEach { section ->
        val shelf = section.musicShelfRenderer
        val carousel = section.musicCarouselShelfRenderer
        val shelfCategory = shelf?.searchCategory()
        shelf?.contents.orEmpty().forEach { item ->
            item.musicResponsiveListItemRenderer?.let { renderer ->
                handleSearchRenderer(renderer, shelfCategory, songs, albums, artists, playlists, videos)
            }
        }
        section.musicCarouselShelfRenderer?.contents.orEmpty().forEach { item ->
            item.musicTwoRowItemRenderer?.let { renderer ->
                when (val parsed = parseCarouselEntry(renderer)) {
                    is AlbumItem -> albums += parsed
                    is ArtistItem -> artists += parsed
                    is PlaylistItem -> playlists += parsed
                }
            }
        }
    }

    return SearchResult(
        songs = songs,
        albums = albums,
        artists = artists,
        playlists = playlists,
        videos = videos
    )
}

fun parseSearchSuggestions(response: SearchSuggestionsResponse): List<String> =
    response.contents.orEmpty().flatMap { content ->
        content.searchSuggestionsSectionRenderer?.contents.orEmpty().mapNotNull { item ->
            item.searchSuggestionRenderer?.navigationEndpoint?.searchEndpoint?.query
        }
    }

fun parseAlbumPage(response: BrowseResponse): AlbumResult {
    val responsiveHeader = response.findResponsiveHeader()
    val legacyHeader = response.header?.musicDetailHeaderRenderer
    val browseId = response.extractBrowseId().orEmpty()

    val title = responsiveHeader?.title.stringValue()
        .ifBlank { legacyHeader?.title.stringValue() }
        .orEmpty()
    val subtitle = responsiveHeader?.subtitle.stringValue()
        .ifBlank { legacyHeader?.subtitle.stringValue() }
    val secondary = responsiveHeader?.secondSubtitle.stringValue()
    val descriptionText = responsiveHeader?.description
        ?.musicDescriptionShelfRenderer?.description.stringValue()

    val subtitleParts = subtitle.toParts()
    val secondaryParts = secondary.toParts()
    val year = (subtitleParts + secondaryParts).firstOrNull { it.matches(yearRegex) }

    val straplineArtists = responsiveHeader?.straplineTextOne?.runs.toArtistItems()
    val fallbackArtistNames = subtitleParts.filter { part ->
        part.isNotBlank() && !part.equals("album", true) && !part.matches(yearRegex)
    }
    val albumArtists = when {
        straplineArtists.isNotEmpty() -> straplineArtists
        fallbackArtistNames.isNotEmpty() -> fallbackArtistNames.map { ArtistItem(name = it) }
        else -> emptyList()
    }

    val description = when {
        !descriptionText.isNullOrBlank() -> descriptionText
        else -> listOf(subtitle, secondary).firstOrNull { !it.isNullOrBlank() }
    }

    val thumbnails = responsiveHeader.collectThumbnails()
        .ifEmpty { legacyHeader.collectThumbnails() }

    val trackFallbackThumbnails = thumbnails
    val tracks = response.trackRenderers()
        .mapNotNull(::parseTrackItem)
        .map { track ->
            if (track.thumbnails.isNotEmpty() || trackFallbackThumbnails.isEmpty()) track
            else track.copy(thumbnails = trackFallbackThumbnails)
        }
        .toList()

    return AlbumResult(
        id = browseId,
        title = title.ifBlank { browseId },
        description = description,
        thumbnails = thumbnails,
        year = year,
        artists = albumArtists,
        tracks = tracks
    )
}

fun parseArtistPage(response: BrowseResponse): ArtistResult {
    val header = response.header?.musicDetailHeaderRenderer
    val name = header?.title.stringValue()
    val description = header?.subtitle.stringValue().takeIf { it.isNotBlank() }

    val songs = mutableListOf<SongItem>()
    val albums = mutableListOf<AlbumItem>()
    val singles = mutableListOf<AlbumItem>()
    val videos = mutableListOf<VideoItem>()

    response.firstTabSections().forEach { section ->
        section.musicShelfRenderer?.let { shelf ->
            val lowered = shelf.title.stringValue().lowercase(Locale.getDefault())
            shelf.contents.orEmpty().forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    when {
                        lowered.contains("video") -> renderer.watchEndpoint()?.videoId?.let { id ->
                            videos += buildVideoItem(renderer, id)
                        }
                        else -> parseTrackItem(renderer)?.let { songs += it }
                    }
                }
            }
        }
        section.musicCarouselShelfRenderer?.contents.orEmpty().forEach { item ->
            item.musicTwoRowItemRenderer?.let { renderer ->
                val album = parseAlbumCarouselItem(renderer)
                if (album != null) {
                    val titleText = renderer.title.stringValue()
                    if (titleText.contains("single", true)) singles += album else albums += album
                }
            }
        }
    }

    return ArtistResult(
        id = "",
        name = name.ifBlank { "" },
        description = description,
        thumbnails = header?.thumbnail?.thumbnails.toThumbnails(),
        songs = songs,
        albums = albums,
        singles = singles,
        videos = videos
    )
}

fun parsePlaylistPage(response: BrowseResponse): PlaylistResult {
    val responsiveHeader = response.findResponsiveHeader()
    val legacyHeader = response.header?.musicDetailHeaderRenderer
    val browseId = response.extractBrowseId().orEmpty()

    val title = responsiveHeader?.title.stringValue()
        .ifBlank { legacyHeader?.title.stringValue() }
        .orEmpty()
    val subtitle = responsiveHeader?.subtitle.stringValue()
        .ifBlank { legacyHeader?.subtitle.stringValue() }
    val secondary = responsiveHeader?.secondSubtitle.stringValue()
    val descriptionText = responsiveHeader?.description
        ?.musicDescriptionShelfRenderer?.description.stringValue()

    val subtitleParts = subtitle.toParts()
    val secondaryParts = secondary.toParts()
    val year = (subtitleParts + secondaryParts).firstOrNull { it.matches(yearRegex) }
    val trackCount = extractFirstNumber(secondary) ?: extractFirstNumber(subtitle)
    val author = responsiveHeader?.straplineTextOne.stringValue().takeIf { it.isNotBlank() }
        ?: subtitleParts.firstOrNull { part ->
            part.isNotBlank() && !part.equals("playlist", true) && !part.matches(yearRegex)
        }

    val description = when {
        !descriptionText.isNullOrBlank() -> descriptionText
        !subtitle.isNullOrBlank() -> subtitle
        else -> null
    }

    val thumbnails = responsiveHeader.collectThumbnails()
        .ifEmpty { legacyHeader.collectThumbnails() }

    val tracks = response.trackRenderers()
        .mapNotNull(::parseTrackItem)
        .toList()

    return PlaylistResult(
        id = browseId,
        title = title.ifBlank { browseId },
        description = description,
        thumbnails = thumbnails,
        author = author,
        year = year,
        trackCount = trackCount,
        tracks = tracks
    )
}

private fun BrowseResponse.trackRenderers(): Sequence<BrowseResponse.MusicResponsiveListItemRenderer> =
    firstTabSections().asSequence().flatMap { it.trackRenderers() }

private fun BrowseResponse.SectionContent.trackRenderers(): Sequence<BrowseResponse.MusicResponsiveListItemRenderer> =
    sequence {
        musicShelfRenderer?.contents.orEmpty().forEach { item ->
            item.musicResponsiveListItemRenderer?.let { yield(it) }
        }
        musicPlaylistShelfRenderer?.contents.orEmpty().forEach { item ->
            item.musicResponsiveListItemRenderer?.let { yield(it) }
        }
    }

private fun BrowseResponse.findResponsiveHeader(): BrowseResponse.MusicResponsiveHeaderRenderer? =
    firstTabSections().firstNotNullOfOrNull { it.musicResponsiveHeaderRenderer }

private fun BrowseResponse.extractBrowseId(): String? =
    responseContext?.serviceTrackingParams.orEmpty()
        .asSequence()
        .flatMap { it.params.orEmpty().asSequence() }
        .firstOrNull { it.key.equals("browse_id", ignoreCase = true) }
        ?.value

private fun String?.toParts(): List<String> =
    this?.split('•')
        ?.map { it.trim() }
        ?.filter { it.isNotEmpty() }
        ?: emptyList()

private fun List<BrowseResponse.Run>?.toArtistItems(): List<ArtistItem> =
    this.orEmpty().mapNotNull { run ->
        val name = run.text.trim()
        if (name.isEmpty() || name == "•") return@mapNotNull null
        val browseId = run.navigationEndpoint?.browseEndpoint?.browseId
        ArtistItem(browseId = browseId, name = name)
    }

fun parseStreamingData(response: PlayerResponse): SongResult {
    val videoDetails = response.videoDetails
    val streamingData = response.streamingData

    
    val adaptiveAudio = streamingData?.adaptiveFormats.orEmpty().filter { it.isAudio }
    val progressiveWithAudio = if (adaptiveAudio.isEmpty()) {
        streamingData?.formats.orEmpty().filter { fmt ->
            fmt.isAudio || fmt.mimeType?.contains("mp4a") == true || fmt.mimeType?.contains("opus") == true
        }
    } else emptyList()

    val chosen = (adaptiveAudio + progressiveWithAudio).distinctBy { it.itag }

    val audioFormats = chosen.map { format ->
        AudioFormat(
            itag = format.itag,
            url = format.url,
            mimeType = format.mimeType,
            bitrate = format.bitrate,
            contentLength = format.contentLength,
            quality = format.quality,
            audioQuality = format.audioQuality,
            audioSampleRate = format.audioSampleRate,
            audioChannels = format.audioChannels
        )
    }

    return SongResult(
        videoId = videoDetails?.videoId ?: "",
        title = videoDetails?.title,
        duration = videoDetails?.lengthSeconds,
        artists = videoDetails?.author?.let { listOf(ArtistItem(name = it, browseId = videoDetails.channelId)) } ?: emptyList(),
        streamingData = StreamingData(
            formats = audioFormats,
            expiresInSeconds = streamingData?.expiresInSeconds
        )
    )
}

private fun handleSearchRenderer(
    renderer: BrowseResponse.MusicResponsiveListItemRenderer,
    shelfCategory: SearchShelfCategory?,
    songs: MutableList<SongItem>,
    albums: MutableList<AlbumItem>,
    artists: MutableList<ArtistItem>,
    playlists: MutableList<PlaylistItem>,
    videos: MutableList<VideoItem>
) {
    val watchEndpoint = renderer.watchEndpoint()
    val candidateVideoId = renderer.playlistItemData?.videoId ?: watchEndpoint?.videoId

    if (candidateVideoId != null && renderer.isVideoResult(shelfCategory, watchEndpoint)) {
        videos += buildVideoItem(renderer, candidateVideoId)
        return
    }

    parseTrackItem(renderer)?.let {
        songs += it
        return
    }

    candidateVideoId?.let { videoId ->
        videos += buildVideoItem(renderer, videoId)
    }

    val browseId = renderer.flexText(0)
        ?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId
        ?: renderer.navigationEndpoint?.browseEndpoint?.browseId
        ?: return

    when {
        browseId.startsWith("MPRE") -> parseAlbumItem(renderer)?.let { albums += it }
        browseId.startsWith("UC") -> parseArtistItem(renderer)?.let { artists += it }
        browseId.startsWith("VL") -> parsePlaylistItem(renderer)?.let { playlists += it }
        else -> parsePlaylistItem(renderer)?.let { playlists += it }
    }
}

private fun parseCarouselEntry(renderer: BrowseResponse.MusicTwoRowItemRenderer): Any? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId
        ?: renderer.playNavigationEndpoint?.watchEndpoint?.playlistId
        ?: return null
    return when {
        browseId.startsWith("MPRE") -> parseAlbumCarouselItem(renderer)
        browseId.startsWith("UC") -> parseArtistCarouselItem(renderer)
        browseId.startsWith("VL") -> parsePlaylistCarouselItem(renderer)
        else -> parsePlaylistCarouselItem(renderer)
    }
}

private fun parseTrackItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): SongItem? {
    val watchEndpoint = renderer.watchEndpoint()
    val videoId = renderer.playlistItemData?.videoId ?: watchEndpoint?.videoId ?: return null

    val title = renderer.flexText(0)?.stringValue()
        ?: renderer.title.stringValue()
    if (title.isBlank()) return null

    val artistRuns = renderer.flexText(1)?.runs ?: renderer.subtitle?.runs
    val artists = artistRuns.toArtistItems()

    val duration = renderer.flexText(2)?.stringValue()
        ?: renderer.secondaryText?.stringValue()
        ?: renderer.fixedColumns?.firstOrNull()
            ?.musicResponsiveListItemFixedColumnRenderer?.text?.stringValue()

    return SongItem(
        videoId = videoId,
        title = title,
        artists = artists,
        duration = duration?.takeIf { it.isNotBlank() },
        thumbnails = renderer.collectThumbnails()
    )
}

private fun parseAlbumItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): AlbumItem? {
    val browseId = renderer.flexText(0)
        ?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId
        ?: renderer.navigationEndpoint?.browseEndpoint?.browseId
        ?: return null

    val title = renderer.flexText(0)?.stringValue()
        ?: renderer.title.stringValue()

    val artistRuns = renderer.flexText(1)?.runs ?: renderer.subtitle?.runs.orEmpty()
    val artists = artistRuns.mapNotNull { run ->
        val browse = run.navigationEndpoint?.browseEndpoint ?: return@mapNotNull null
        ArtistItem(browseId = browse.browseId, name = run.text)
    }
    val year = renderer.flexText(2)?.stringValue()?.takeIf { it.isNotBlank() }

    return AlbumItem(
        browseId = browseId,
        title = title.ifBlank { browseId },
        artists = artists,
        year = year,
        thumbnails = renderer.collectThumbnails()
    )
}

private fun parseArtistItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): ArtistItem? {
    val browseId = renderer.flexText(0)
        ?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId
        ?: renderer.navigationEndpoint?.browseEndpoint?.browseId
        ?: return null
    val name = renderer.flexText(0)?.stringValue()
        ?: renderer.title.stringValue()

    return ArtistItem(
        browseId = browseId,
        name = name.ifBlank { browseId },
        thumbnails = renderer.collectThumbnails()
    )
}

private fun parsePlaylistItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): PlaylistItem? {
    val browseId = renderer.flexText(0)
        ?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId
        ?: renderer.navigationEndpoint?.browseEndpoint?.browseId
        ?: return null
    val title = renderer.flexText(0)?.stringValue()
        ?: renderer.title.stringValue()

    return PlaylistItem(
        browseId = browseId,
        title = title.ifBlank { browseId },
        thumbnails = renderer.collectThumbnails()
    )
}

private fun BrowseResponse.MusicResponsiveListItemRenderer.watchEndpoint(): BrowseResponse.WatchEndpoint? =
    playNavigationEndpoint?.watchEndpoint
        ?: navigationEndpoint?.watchEndpoint
        ?: overlay?.musicItemThumbnailOverlayRenderer
            ?.content?.musicPlayButtonRenderer
            ?.playNavigationEndpoint?.watchEndpoint

private fun BrowseResponse.MusicResponsiveListItemRenderer.isVideoResult(
    categoryHint: SearchShelfCategory?,
    watchEndpoint: BrowseResponse.WatchEndpoint?
): Boolean {
    if (categoryHint == SearchShelfCategory.VIDEOS) return true
    if (categoryHint == SearchShelfCategory.SONGS) return false
    val musicVideoType = watchEndpoint
        ?.watchEndpointMusicSupportedConfigs
        ?.watchEndpointMusicConfig
        ?.musicVideoType
        ?.uppercase(Locale.ROOT)
        ?: return false
    return musicVideoType != "MUSIC_VIDEO_TYPE_ATV"
}

private fun BrowseResponse.MusicShelfRenderer.searchCategory(): SearchShelfCategory? {
    val candidates = sequenceOf(title.stringValue(), subtitle.stringValue())
        .map { it.normalizeSearchCategoryText() }
        .filter { it.isNotEmpty() }

    for (text in candidates) {
        val match = searchCategoryKeywords.entries.firstOrNull { (_, keywords) ->
            text.containsAnyKeyword(keywords)
        }?.key
        if (match != null) return match
    }
    return null
}

private fun String.containsAnyKeyword(keywords: Set<String>): Boolean =
    keywords.any { keyword -> keyword.isNotEmpty() && this.contains(keyword) }

private fun String.normalizeSearchCategoryText(): String =
    Normalizer.normalize(this, Normalizer.Form.NFD)
        .replace(diacriticsRegex, "")
        .lowercase(Locale.ROOT)
        .trim()

private fun parseAlbumCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): AlbumItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.title.stringValue()
    return AlbumItem(
        browseId = browseId,
        title = title.ifBlank { browseId },
        artists = extractCarouselArtists(renderer.subtitle?.runs.orEmpty()),
        thumbnails = renderer.collectThumbnails()
    )
}

private fun parseArtistCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): ArtistItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val name = renderer.title.stringValue()
    return ArtistItem(
        browseId = browseId,
        name = name.ifBlank { browseId },
        thumbnails = renderer.collectThumbnails()
    )
}

private fun parsePlaylistCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): PlaylistItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.title.stringValue()
    return PlaylistItem(
        browseId = browseId,
        title = title.ifBlank { browseId },
        thumbnails = renderer.collectThumbnails()
    )
}

private fun buildVideoItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer, videoId: String): VideoItem {
    val title = renderer.flexText(0)?.stringValue()
        ?: renderer.title.stringValue()
    val author = renderer.flexText(1)?.runs?.firstOrNull()?.text
        ?: renderer.subtitle?.runs?.firstOrNull()?.text
    val duration = renderer.flexText(2)?.stringValue()
        ?: renderer.secondaryText?.stringValue()
    return VideoItem(
        videoId = videoId,
        title = title.ifBlank { videoId },
        author = author,
        duration = duration,
        thumbnails = renderer.collectThumbnails()
    )
}

private fun BrowseResponse.firstTabSections(): List<BrowseResponse.SectionContent> {
    val sections = mutableListOf<BrowseResponse.SectionContent>()
    contents?.singleColumnBrowseResultsRenderer?.tabs.orEmpty()
        .firstOrNull()?.tabRenderer?.content?.sectionListRenderer?.contents
        ?.let { sections += it }
    contents?.sectionListRenderer?.contents?.let { sections += it }
    contents?.tabbedSearchResultsRenderer?.tabs.orEmpty()
        .firstOrNull()?.tabRenderer?.content?.sectionListRenderer?.contents
        ?.let { sections += it }
    contents?.twoColumnBrowseResultsRenderer?.tabs.orEmpty()
        .firstOrNull()?.tabRenderer?.content?.sectionListRenderer?.contents
        ?.let { sections += it }
    contents?.twoColumnBrowseResultsRenderer?.primaryContents
        ?.sectionListRenderer?.contents?.let { sections += it }
    contents?.twoColumnBrowseResultsRenderer?.secondaryContents
        ?.sectionListRenderer?.contents?.let { sections += it }
    continuationContents?.sectionListContinuation?.contents?.let { sections += it }
    return sections
}

private fun BrowseResponse.TextRuns?.stringValue(): String =
    this?.simpleText ?: this?.runs.orEmpty().joinToString("") { it.text }

private fun BrowseResponse.MusicResponsiveListItemRenderer.flexText(index: Int): BrowseResponse.TextRuns? =
    flexColumns?.getOrNull(index)?.musicResponsiveListItemFlexColumnRenderer?.text

private fun BrowseResponse.MusicResponsiveListItemRenderer.collectThumbnails(): List<Thumbnail> =
    (thumbnail?.musicThumbnailRenderer?.thumbnail?.thumbnails
        ?: thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails).toThumbnails()

private fun BrowseResponse.MusicTwoRowItemRenderer.collectThumbnails(): List<Thumbnail> =
    thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails.toThumbnails()

private fun List<BrowseResponse.ThumbnailImage>?.toThumbnails(): List<Thumbnail> =
    this?.map { Thumbnail(url = it.url, width = it.width, height = it.height) } ?: emptyList()

private fun BrowseResponse.MusicResponsiveHeaderRenderer?.collectThumbnails(): List<Thumbnail> =
    this?.thumbnail?.musicThumbnailRenderer?.thumbnail?.thumbnails.toThumbnails()

private fun BrowseResponse.MusicDetailHeaderRenderer?.collectThumbnails(): List<Thumbnail> =
    this?.thumbnail?.thumbnails.toThumbnails()

private fun extractCarouselArtists(runs: List<BrowseResponse.Run>?): List<ArtistItem> =
    runs.orEmpty().mapNotNull { run ->
        val browse = run.navigationEndpoint?.browseEndpoint ?: return@mapNotNull null
        ArtistItem(browseId = browse.browseId, name = run.text)
    }

private fun extractFirstNumber(text: String?): Int? =
    text?.let { Regex("\\d+").find(it)?.value?.toIntOrNull() }

fun parseHomePage(response: BrowseResponse): HomeResult {
    val jsonElement = jsonFormatter.encodeToJsonElement(BrowseResponse.serializer(), response)
    val collector = HomeSectionCollector(jsonElement)
    val (sections, tokens) = collector.toResult()
    return HomeResult(
        loggedIn = isLoggedIn(response.responseContext),
        sections = sections,
        continuationTokens = tokens
    )
}

private fun isLoggedIn(context: ResponseContext?): Boolean =
    context?.serviceTrackingParams.orEmpty().any { service ->
        service.params.orEmpty().any { param ->
            val key = param.key.lowercase(Locale.US)
            val value = param.value
            (key == "logged_in" || key == "yt_li") && value == "1"
        }
    }

private class HomeSectionCollector(root: JsonElement) {
    private val sectionOrder = mutableListOf<String>()
    private val sections = LinkedHashMap<String, MutableSection>()
    private val tokens = LinkedHashSet<String>()
    private var counter = 0

    init { visit(root) }

    fun toResult(): Pair<List<HomeSection>, List<String>> {
        val sectionList = sectionOrder.mapNotNull { key ->
            val section = sections[key] ?: return@mapNotNull null
            HomeSection(
                key = section.key,
                title = section.title,
                items = section.items.toList()
            )
        }
        return sectionList to tokens.toList()
    }

    private fun visit(element: JsonElement?) {
        when (element) {
            is JsonObject -> {
                element["musicCarouselShelfRenderer"]?.obj()?.let { renderer ->
                    buildSectionFromCarousel(renderer)?.let { addSection(it) }
                }
                element["musicShelfRenderer"]?.obj()?.let { renderer ->
                    buildSectionFromShelf(renderer)?.let { addSection(it) }
                }
                element["nextContinuationData"]?.obj()?.get("continuation")?.stringOrNull()?.let(::addToken)
                element["continuationCommand"]?.obj()?.get("token")?.stringOrNull()?.let(::addToken)
                element["continuationEndpoint"]?.obj()
                    ?.get("continuationCommand")?.obj()
                    ?.get("token")?.stringOrNull()?.let(::addToken)
                element["reloadContinuationData"]?.obj()?.get("continuation")?.stringOrNull()?.let(::addToken)
                element.values.forEach { visit(it) }
            }
            is JsonArray -> element.forEach { visit(it) }
            is JsonPrimitive, null -> Unit
        }
    }

    private fun addToken(token: String) {
        if (token.isNotBlank()) tokens += token
    }

    private fun addSection(candidate: HomeSectionCandidate) {
        val normalizedKey = candidate.key?.takeIf { it.isNotBlank() } ?: "section-${counter++}"
        val entry = sections.getOrPut(normalizedKey) {
            sectionOrder += normalizedKey
            MutableSection(key = normalizedKey, title = candidate.title, items = mutableListOf(), itemKeys = mutableSetOf())
        }
        if (entry.title.isNullOrBlank()) {
            entry.title = candidate.title
        }
        candidate.items.forEach { item ->
            val itemKey = createItemKey(item)
            if (entry.itemKeys.add(itemKey)) entry.items += item
        }
    }

    private fun buildSectionFromCarousel(renderer: JsonObject): HomeSectionCandidate? {
        val headerTitle = textFromRuns(
            renderer["header"]?.obj()
                ?.get("musicCarouselShelfBasicHeaderRenderer")?.obj()
                ?.get("title")
        )
        val fallbackTitle = textFromRuns(renderer["title"])
        val title = headerTitle.ifBlank { fallbackTitle }
        val items = extractMusicItems(renderer["contents"]?.array())
        if (items.isEmpty()) return null
        val key = deriveSectionKey("carousel", renderer, title, items)
        return HomeSectionCandidate(key, title.takeIf { it.isNotBlank() }, items)
    }

    private fun buildSectionFromShelf(renderer: JsonObject): HomeSectionCandidate? {
        val title = textFromRuns(renderer["title"])
        val items = extractMusicItems(renderer["contents"]?.array())
        if (items.isEmpty()) return null
        val key = deriveSectionKey("shelf", renderer, title, items)
        return HomeSectionCandidate(key, title.takeIf { it.isNotBlank() }, items)
    }

    private fun extractMusicItems(itemsNode: JsonArray?): List<HomeItem> =
        itemsNode?.mapNotNull { element ->
            val obj = element.obj() ?: return@mapNotNull null
            obj["musicTwoRowItemRenderer"]?.obj()?.let { parseMusicTwoRow(it) }
                ?: obj["musicResponsiveListItemRenderer"]?.obj()?.let { parseMusicResponsive(it) }
        } ?: emptyList()

    private fun parseMusicTwoRow(renderer: JsonObject): HomeItem? {
        val name = textFromRuns(renderer["title"]).ifBlank { return null }
        val endpoint = renderer["navigationEndpoint"]?.obj()
            ?: renderer["playNavigationEndpoint"]?.obj()
            ?: renderer["thumbnailOverlay"]?.obj()
                ?.get("musicItemThumbnailOverlayRenderer")?.obj()
                ?.get("content")?.obj()
                ?.get("musicPlayButtonRenderer")?.obj()
                ?.get("playNavigationEndpoint")?.obj()
        val idInfo = resolveNavigationId(endpoint) ?: return null
        val browseParams = endpoint
            ?.get("browseEndpoint")?.obj()
            ?.get("params")?.stringOrNull()
        val authorRuns = renderer["subtitle"]?.obj()?.get("runs")?.array()
        val authors = extractAuthorsFromRuns(authorRuns)
        return HomeItem(
            name = name,
            author = authors.takeIf { it.isNotEmpty() }?.joinToString(", "),
            videoId = idInfo.takeIf { it.first == "videoId" }?.second,
            playlistId = idInfo.takeIf { it.first == "playlistId" }?.second,
            browseId = idInfo.takeIf { it.first == "browseId" }?.second,
            image = entryImage(renderer),
            params = browseParams
        )
    }

    private fun parseMusicResponsive(renderer: JsonObject): HomeItem? {
        val title = textFromRuns(
            renderer["flexColumns"]?.array()?.getOrNull(0)?.obj()
                ?.get("musicResponsiveListItemFlexColumnRenderer")?.obj()
                ?.get("text")
        ).ifBlank { textFromRuns(renderer["title"]) }
        if (title.isBlank()) return null
        val endpoint = renderer["navigationEndpoint"]?.obj()
            ?: renderer["playNavigationEndpoint"]?.obj()
            ?: renderer["overlay"]?.obj()
                ?.get("musicItemThumbnailOverlayRenderer")?.obj()
                ?.get("content")?.obj()
                ?.get("musicPlayButtonRenderer")?.obj()
                ?.get("playNavigationEndpoint")?.obj()
        val idInfo = resolveNavigationId(endpoint) ?: return null
        val browseParams = endpoint
            ?.get("browseEndpoint")?.obj()
            ?.get("params")?.stringOrNull()
        val authorRuns = renderer["flexColumns"]?.array()?.getOrNull(1)?.obj()
            ?.get("musicResponsiveListItemFlexColumnRenderer")?.obj()
            ?.get("text")?.obj()?.get("runs")?.array()
            ?: renderer["subtitle"]?.obj()?.get("runs")?.array()
        val authors = extractAuthorsFromRuns(authorRuns)
        return HomeItem(
            name = title,
            author = authors.takeIf { it.isNotEmpty() }?.joinToString(", "),
            videoId = idInfo.takeIf { it.first == "videoId" }?.second,
            playlistId = idInfo.takeIf { it.first == "playlistId" }?.second,
            browseId = idInfo.takeIf { it.first == "browseId" }?.second,
            image = entryImage(renderer),
            params = browseParams
        )
    }

    private fun extractAuthorsFromRuns(runs: JsonArray?): List<String> {
        if (runs == null) return emptyList()
        val explicit = runs.mapNotNull { element ->
            val run = element.obj() ?: return@mapNotNull null
            val browse = run["navigationEndpoint"]?.obj()?.get("browseEndpoint")?.obj()
            val browseId = browse?.get("browseId")?.stringOrNull().orEmpty()
            val pageType = browse
                ?.get("browseEndpointContextSupportedConfigs")?.obj()
                ?.get("browseEndpointContextMusicConfig")?.obj()
                ?.get("pageType")?.stringOrNull().orEmpty()
            if (pageType == "MUSIC_PAGE_TYPE_ARTIST" || browseId.startsWith("UC")) {
                run["text"]?.stringOrNull()?.trim()?.takeIf { it.isNotBlank() }
            } else null
        }
        if (explicit.isNotEmpty()) return explicit
        val joined = runs.mapNotNull { it.obj()?.get("text")?.stringOrNull()?.trim()?.takeIf { it.isNotBlank() } }
            .joinToString(" ")
        if (joined.isBlank()) return emptyList()
        val truncated = joined.split(" • ").firstOrNull().orEmpty().trim()
        return if (truncated.isBlank()) emptyList() else listOf(truncated)
    }

    private fun deriveSectionKey(type: String, renderer: JsonObject, title: String?, items: List<HomeItem>): String? {
        renderer["shelfId"]?.stringOrNull()?.takeIf { it.isNotBlank() }?.let { return it }
        renderer["trackingParams"]?.stringOrNull()?.takeIf { it.isNotBlank() }?.let { return "$type:$it" }
        val firstId = items.firstOrNull()?.primaryKey()
        return when {
            !title.isNullOrBlank() && !firstId.isNullOrBlank() -> "$type:$title:$firstId"
            !title.isNullOrBlank() -> "$type:$title"
            else -> null
        }
    }
}

private data class MutableSection(
    val key: String,
    var title: String?,
    val items: MutableList<HomeItem>,
    val itemKeys: MutableSet<String>,
)

private data class HomeSectionCandidate(
    val key: String?,
    val title: String?,
    val items: List<HomeItem>,
)

private fun HomeItem.primaryKey(): String? = videoId ?: playlistId ?: browseId

private fun createItemKey(item: HomeItem): String =
    item.videoId ?: item.playlistId ?: item.browseId ?: "${item.name}::${item.author ?: ""}::${item.image ?: ""}"

private fun resolveNavigationId(endpoint: JsonObject?): Pair<String, String>? {
    if (endpoint == null) return null
    endpoint["watchEndpoint"]?.obj()?.get("videoId")?.stringOrNull()?.takeIf { it.isNotBlank() }
        ?.let { return "videoId" to it }
    endpoint["watchEndpoint"]?.obj()?.get("playlistId")?.stringOrNull()?.takeIf { it.isNotBlank() }
        ?.let { return "playlistId" to it }
    endpoint["watchPlaylistEndpoint"]?.obj()?.get("playlistId")?.stringOrNull()?.takeIf { it.isNotBlank() }
        ?.let { return "playlistId" to it }
    val browse = endpoint["browseEndpoint"]?.obj()
    val browseId = browse?.get("browseId")?.stringOrNull()
    if (!browseId.isNullOrBlank()) {
        val pageType = browse["browseEndpointContextSupportedConfigs"]?.obj()
            ?.get("browseEndpointContextMusicConfig")?.obj()
            ?.get("pageType")?.stringOrNull().orEmpty()
        return if (pageType != "MUSIC_PAGE_TYPE_ARTIST" && !browseId.startsWith("UC")) {
            "playlistId" to browseId
        } else {
            "browseId" to browseId
        }
    }
    return null
}

private fun textFromRuns(element: JsonElement?): String {
    val obj = element.obj() ?: return ""
    obj["simpleText"]?.stringOrNull()?.let { return it }
    val runs = obj["runs"]?.array() ?: return ""
    return runs.joinToString("") { run -> run.obj()?.get("text")?.stringOrNull().orEmpty() }
}

private fun entryImage(renderer: JsonObject): String? {
    val sources = listOfNotNull(
        renderer["thumbnailRenderer"]?.obj()
            ?.get("musicThumbnailRenderer")?.obj()
            ?.get("thumbnail")?.obj()?.get("thumbnails")?.array(),
        renderer["thumbnail"]?.obj()
            ?.get("musicThumbnailRenderer")?.obj()
            ?.get("thumbnail")?.obj()?.get("thumbnails")?.array(),
        renderer["thumbnail"]?.obj()?.get("thumbnails")?.array(),
        renderer["thumbnailRenderers"]?.array()?.firstOrNull()?.obj()
            ?.get("musicThumbnailRenderer")?.obj()
            ?.get("thumbnail")?.obj()?.get("thumbnails")?.array()
    )
    for (source in sources) {
        val candidate = pickBestThumbnail(source)
        if (candidate != null) return candidate
    }
    return null
}

private fun pickBestThumbnail(array: JsonArray?): String? =
    array?.mapNotNull { element ->
        val obj = element.obj() ?: return@mapNotNull null
        val url = obj["url"]?.stringOrNull() ?: return@mapNotNull null
        val width = obj["width"]?.stringOrNull()?.toIntOrNull() ?: 0
        url to width
    }?.maxByOrNull { it.second }?.first

private fun JsonElement?.obj(): JsonObject? = this as? JsonObject

private fun JsonElement?.array(): JsonArray? = this as? JsonArray

private fun JsonElement?.stringOrNull(): String? =
    (this as? JsonPrimitive)?.contentOrNull
