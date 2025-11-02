package com.rmusic.providers.intermusic.models.response

import com.rmusic.providers.intermusic.pages.Thumbnail
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PlayerResponse(
    val responseContext: ResponseContext? = null,
    val playabilityStatus: PlayabilityStatus? = null,
    val streamingData: StreamingData? = null,
    val videoDetails: VideoDetails? = null,
    val playbackTracking: PlaybackTracking? = null,
    val captions: Captions? = null,
    val playerConfig: PlayerConfig? = null,
) {
    @Serializable
    data class PlayabilityStatus(
        val status: String,
        val reason: String? = null,
    )

    @Serializable
    data class StreamingData(
        val expiresInSeconds: String? = null,
        val formats: List<Format>? = null,
        val adaptiveFormats: List<Format>? = null,
    val serverAbrStreamingUrl: String? = null,
    val hlsManifestUrl: String? = null,
    val dashManifestUrl: String? = null,
    )

    @Serializable
    data class Format(
        val itag: Int,
        val url: String? = null,
        val mimeType: String? = null,
        val bitrate: Int? = null,
        val averageBitrate: Int? = null,
        val width: Int? = null,
        val height: Int? = null,
        val initRange: Range? = null,
        val indexRange: Range? = null,
        val contentLength: String? = null,
        val quality: String? = null,
        val fps: Int? = null,
        val qualityLabel: String? = null,
        val audioQuality: String? = null,
        val audioSampleRate: String? = null,
        val audioChannels: Int? = null,
        val loudnessDb: Float? = null,
    ) {
        
        val isAudio: Boolean
            get() = mimeType?.lowercase()?.let { mime ->
                mime.startsWith("audio/") || 
                mime.contains("mp4a") || 
                mime.contains("opus") || 
                mime.contains("vorbis")
            } ?: (audioQuality != null)

        /**
         * Some fallback progressive formats are video+audio (mimeType starts with video/).
         * If no pure audio format exists we may still use them. We treat a video format
         * as containing audio if its mimeType has an audio codec marker (mp4a or opus).
         */
        val hasEmbeddedAudio: Boolean
            get() = !isAudio && (mimeType?.contains("mp4a") == true || mimeType?.contains("opus") == true)

    // campos relacionados a cipher eliminados
    }

    @Serializable
    data class Range(
        val start: String,
        val end: String,
    )

    @Serializable
    data class VideoDetails(
        val videoId: String,
        val title: String? = null,
        val lengthSeconds: String? = null,
        val channelId: String? = null,
        val author: String? = null,
        val isLiveContent: Boolean? = null,
    )

    @Serializable
    data class PlaybackTracking(
        val videostatsPlaybackUrl: Url? = null,
        val videostatsDelayplayUrl: Url? = null,
    ) {
        @Serializable
        data class Url(
            val baseUrl: String,
        )
    }

    
    @Serializable
    data class Captions(
        val playerCaptionsTracklistRenderer: PlayerCaptionsTracklistRenderer? = null,
    ) {
        @Serializable
        data class PlayerCaptionsTracklistRenderer(
            val captionTracks: List<CaptionTrack>? = null,
            val translationLanguages: List<TranslationLanguage>? = null,
        )

        @Serializable
        data class CaptionTrack(
            val baseUrl: String? = null,
            val name: Text? = null,
            val languageCode: String? = null,
            val kind: String? = null,
        )

        @Serializable
        data class TranslationLanguage(
            val languageCode: String? = null,
            val languageName: Text? = null,
        )

        @Serializable
        data class Text(
            val simpleText: String? = null,
        )
    }

    @Serializable
    data class PlayerConfig(
        val audioConfig: AudioConfig? = null,
    ) {
        @Serializable
        data class AudioConfig(
            val loudnessDb: Float? = null,
        )
    }
}

@Serializable
data class ResponseContext(
    val serviceTrackingParams: List<ServiceTrackingParam>? = null,
) {
    @Serializable
    data class ServiceTrackingParam(
        val service: String,
        val params: List<Param>? = null,
    ) {
        @Serializable
        data class Param(
            val key: String,
            val value: String,
        )
    }
}

@Serializable
data class BrowseResponse(
    val responseContext: ResponseContext? = null,
    val contents: Contents? = null,
    val continuationContents: ContinuationContents? = null,
    val header: Header? = null,
) {
    @Serializable
    data class Contents(
        val singleColumnBrowseResultsRenderer: SingleColumnBrowseResultsRenderer? = null,
    )

    @Serializable
    data class SingleColumnBrowseResultsRenderer(
        val tabs: List<Tab>? = null,
    )

    @Serializable
    data class Tab(
        val tabRenderer: TabRenderer? = null,
    )

    @Serializable
    data class TabRenderer(
        val content: Content? = null,
    )

    @Serializable
    data class Content(
        val sectionListRenderer: SectionListRenderer? = null,
    )

    @Serializable
    data class SectionListRenderer(
        val contents: List<SectionContent>? = null,
    )

    @Serializable
    data class SectionContent(
        val musicShelfRenderer: MusicShelfRenderer? = null,
        val musicCarouselShelfRenderer: MusicCarouselShelfRenderer? = null,
    )

    @Serializable
    data class MusicShelfRenderer(
        val contents: List<MusicItemRenderer>? = null,
        val continuations: List<Continuation>? = null,
    )

    @Serializable
    data class MusicCarouselShelfRenderer(
        val contents: List<MusicItemRenderer>? = null,
    )

    @Serializable
    data class MusicItemRenderer(
        val musicResponsiveListItemRenderer: MusicResponsiveListItemRenderer? = null,
        val musicTwoRowItemRenderer: MusicTwoRowItemRenderer? = null,
    )

    @Serializable
    data class MusicResponsiveListItemRenderer(
        val flexColumns: List<FlexColumn>? = null,
        val fixedColumns: List<FixedColumn>? = null,
        val playNavigationEndpoint: PlayNavigationEndpoint? = null,
        val menu: Menu? = null,
    )

    @Serializable
    data class MusicTwoRowItemRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
        val thumbnailRenderer: ThumbnailRenderer? = null,
    )

    @Serializable
    data class FlexColumn(
        val text: TextRuns? = null,
    )

    @Serializable
    data class FixedColumn(
        val text: TextRuns? = null,
    )

    @Serializable
    data class TextRuns(
        val runs: List<Run>? = null,
    )

    @Serializable
    data class Run(
        val text: String,
        val navigationEndpoint: NavigationEndpoint? = null,
    )

    @Serializable
    data class NavigationEndpoint(
        val browseEndpoint: BrowseEndpoint? = null,
        val watchEndpoint: WatchEndpoint? = null,
    )

    @Serializable
    data class BrowseEndpoint(
        val browseId: String,
        val params: String? = null,
    )

    @Serializable
    data class WatchEndpoint(
        val videoId: String,
        val playlistId: String? = null,
        val playlistSetVideoId: String? = null,
        val index: Int? = null,
        val params: String? = null,
    )

    @Serializable
    data class PlayNavigationEndpoint(
        val watchEndpoint: WatchEndpoint? = null,
    )

    @Serializable
    data class Menu(
        val menuRenderer: MenuRenderer? = null,
    )

    @Serializable
    data class MenuRenderer(
        val items: List<MenuItem>? = null,
    )

    @Serializable
    data class MenuItem(
        val menuNavigationItemRenderer: MenuNavigationItemRenderer? = null,
    )

    @Serializable
    data class MenuNavigationItemRenderer(
        val text: TextRuns? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
    )

    @Serializable
    data class ThumbnailRenderer(
        val musicThumbnailRenderer: MusicThumbnailRenderer? = null,
    )

    @Serializable
    data class MusicThumbnailRenderer(
        val thumbnail: Thumbnail? = null,
    )

    @Serializable
    data class Thumbnail(
        val thumbnails: List<ThumbnailImage>? = null,
    )

    @Serializable
    data class ThumbnailImage(
        val url: String,
        val width: Int? = null,
        val height: Int? = null,
    )

    @Serializable
    data class ContinuationContents(
        val musicShelfContinuation: MusicShelfContinuation? = null,
    )

    @Serializable
    data class MusicShelfContinuation(
        val contents: List<MusicItemRenderer>? = null,
        val continuations: List<Continuation>? = null,
    )

    @Serializable
    data class Continuation(
        val nextContinuationData: NextContinuationData? = null,
    )

    @Serializable
    data class NextContinuationData(
        val continuation: String,
    )

    @Serializable
    data class Header(
        val musicDetailHeaderRenderer: MusicDetailHeaderRenderer? = null,
    )

    @Serializable
    data class MusicDetailHeaderRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
        val thumbnail: Thumbnail? = null,
    )
}

@Serializable
data class LibraryResponse(
    val contents: LibraryContents? = null,
    val header: LibraryHeader? = null,
) {
    @Serializable
    data class LibraryContents(
        val singleColumnBrowseResultsRenderer: SingleColumnBrowseResultsRenderer? = null,
    )

    @Serializable
    data class SingleColumnBrowseResultsRenderer(
        val tabs: List<LibraryTab>? = null,
    )

    @Serializable
    data class LibraryTab(
        val tabRenderer: LibraryTabRenderer? = null,
    )

    @Serializable
    data class LibraryTabRenderer(
        val content: LibraryTabContent? = null,
    )

    @Serializable
    data class LibraryTabContent(
        val sectionListRenderer: LibrarySectionListRenderer? = null,
    )

    @Serializable
    data class LibrarySectionListRenderer(
        val contents: List<LibrarySectionContent>? = null,
    )

    @Serializable
    data class LibrarySectionContent(
        val musicShelfRenderer: MusicShelfRenderer? = null,
        val gridRenderer: GridRenderer? = null,
    )

    @Serializable
    data class LibraryHeader(
        val musicHeaderRenderer: LibraryMusicHeaderRenderer? = null,
    )

    @Serializable
    data class LibraryMusicHeaderRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
    )

    @Serializable
    data class GridRenderer(
        val items: List<GridItem>? = null,
        val header: GridHeader? = null,
    )

    @Serializable
    data class GridItem(
        val musicTwoRowItemRenderer: MusicTwoRowItemRenderer? = null,
        val musicNavigationButtonRenderer: MusicNavigationButtonRenderer? = null,
    )

    @Serializable
    data class GridHeader(
        val gridHeaderRenderer: GridHeaderRenderer? = null,
    )

    @Serializable
    data class GridHeaderRenderer(
        val title: TextRuns? = null,
    )

    @Serializable
    data class MusicNavigationButtonRenderer(
        val text: TextRuns? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
    )
}
