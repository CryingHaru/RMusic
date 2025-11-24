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
        val twoColumnBrowseResultsRenderer: TwoColumnBrowseResultsRenderer? = null,
        val tabbedSearchResultsRenderer: TabbedSearchResultsRenderer? = null,
        val sectionListRenderer: SectionListRenderer? = null,
    )

    @Serializable
    data class TwoColumnBrowseResultsRenderer(
        val tabs: List<Tab>? = null,
        val primaryContents: SectionListRendererContainer? = null,
        val secondaryContents: SectionListRendererContainer? = null,
    )

    @Serializable
    data class SectionListRendererContainer(
        val sectionListRenderer: SectionListRenderer? = null,
    )

    @Serializable
    data class SingleColumnBrowseResultsRenderer(
        val tabs: List<Tab>? = null,
    )

    @Serializable
    data class TabbedSearchResultsRenderer(
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
        val continuations: List<Continuation>? = null,
    )

    @Serializable
    data class SectionContent(
        val musicShelfRenderer: MusicShelfRenderer? = null,
        val musicPlaylistShelfRenderer: MusicPlaylistShelfRenderer? = null,
        val musicCarouselShelfRenderer: MusicCarouselShelfRenderer? = null,
        val musicResponsiveHeaderRenderer: MusicResponsiveHeaderRenderer? = null,
    )

    @Serializable
    data class MusicShelfRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
        val contents: List<MusicItemRenderer>? = null,
        val continuations: List<Continuation>? = null,
        val shelfId: String? = null,
        val trackingParams: String? = null,
    )

    @Serializable
    data class MusicPlaylistShelfRenderer(
        val playlistId: String? = null,
        val contents: List<MusicItemRenderer>? = null,
        val continuations: List<Continuation>? = null,
        val trackingParams: String? = null,
    )

    @Serializable
    data class MusicCarouselShelfRenderer(
        val header: MusicCarouselShelfHeader? = null,
        val title: TextRuns? = null,
        val contents: List<MusicItemRenderer>? = null,
        val trackingParams: String? = null,
        val shelfId: String? = null,
    )

    @Serializable
    data class MusicResponsiveHeaderRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
        val secondSubtitle: TextRuns? = null,
        val straplineTextOne: TextRuns? = null,
        val straplineThumbnail: ThumbnailRenderer? = null,
        val thumbnail: ThumbnailRenderer? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
        val description: Description? = null,
    ) {
        @Serializable
        data class Description(
            val musicDescriptionShelfRenderer: MusicDescriptionShelfRenderer? = null,
        )

        @Serializable
        data class MusicDescriptionShelfRenderer(
            val description: TextRuns? = null,
        )
    }

    @Serializable
    data class MusicCarouselShelfHeader(
        val musicCarouselShelfBasicHeaderRenderer: MusicCarouselShelfBasicHeaderRenderer? = null,
    )

    @Serializable
    data class MusicCarouselShelfBasicHeaderRenderer(
        val title: TextRuns? = null,
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
        val navigationEndpoint: NavigationEndpoint? = null,
        val menu: Menu? = null,
        val subtitle: TextRuns? = null,
        val title: TextRuns? = null,
        val primaryText: TextRuns? = null,
        val secondaryText: TextRuns? = null,
        val thumbnail: ThumbnailRenderer? = null,
        val thumbnailRenderer: ThumbnailRenderer? = null,
        val overlay: ThumbnailOverlay? = null,
        val playlistItemData: PlaylistItemData? = null,
        val trackingParams: String? = null,
    )

    @Serializable
    data class PlaylistItemData(
        val videoId: String? = null,
        val playlistSetVideoId: String? = null,
    )

    @Serializable
    data class MusicTwoRowItemRenderer(
        val title: TextRuns? = null,
        val subtitle: TextRuns? = null,
        val navigationEndpoint: NavigationEndpoint? = null,
        val playNavigationEndpoint: PlayNavigationEndpoint? = null,
        val thumbnailOverlay: ThumbnailOverlay? = null,
        val thumbnailRenderer: ThumbnailRenderer? = null,
        val trackingParams: String? = null,
    )

    @Serializable
    data class FlexColumn(
        val musicResponsiveListItemFlexColumnRenderer: MusicResponsiveListItemFlexColumnRenderer? = null,
    ) {
        @Serializable
        data class MusicResponsiveListItemFlexColumnRenderer(
            val text: TextRuns? = null,
        )
    }

    @Serializable
    data class FixedColumn(
        val musicResponsiveListItemFixedColumnRenderer: MusicResponsiveListItemFixedColumnRenderer? = null,
    ) {
        @Serializable
        data class MusicResponsiveListItemFixedColumnRenderer(
            val text: TextRuns? = null,
        )
    }

    @Serializable
    data class TextRuns(
        val runs: List<Run>? = null,
        val simpleText: String? = null,
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
        val watchPlaylistEndpoint: WatchPlaylistEndpoint? = null,
        val continuationEndpoint: ContinuationEndpoint? = null,
        val continuationCommand: ContinuationCommand? = null,
    )

    @Serializable
    data class BrowseEndpoint(
        val browseId: String,
        val params: String? = null,
        val browseEndpointContextSupportedConfigs: BrowseEndpointContextSupportedConfigs? = null,
    )

    @Serializable
    data class BrowseEndpointContextSupportedConfigs(
        val browseEndpointContextMusicConfig: BrowseEndpointContextMusicConfig? = null,
    )

    @Serializable
    data class BrowseEndpointContextMusicConfig(
        val pageType: String? = null,
    )

    @Serializable
    data class WatchEndpoint(
        val videoId: String,
        val playlistId: String? = null,
        val playlistSetVideoId: String? = null,
        val index: Int? = null,
        val params: String? = null,
        val watchEndpointMusicSupportedConfigs: WatchEndpointMusicSupportedConfigs? = null,
    ) {
        @Serializable
        data class WatchEndpointMusicSupportedConfigs(
            val watchEndpointMusicConfig: WatchEndpointMusicConfig? = null,
        )

        @Serializable
        data class WatchEndpointMusicConfig(
            val musicVideoType: String? = null,
        )
    }

    @Serializable
    data class WatchPlaylistEndpoint(
        val playlistId: String? = null,
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
    data class ThumbnailOverlay(
        val musicItemThumbnailOverlayRenderer: MusicItemThumbnailOverlayRenderer? = null,
    )

    @Serializable
    data class MusicItemThumbnailOverlayRenderer(
        val content: MusicItemThumbnailOverlayContent? = null,
    )

    @Serializable
    data class MusicItemThumbnailOverlayContent(
        val musicPlayButtonRenderer: MusicPlayButtonRenderer? = null,
    )

    @Serializable
    data class MusicPlayButtonRenderer(
        val playNavigationEndpoint: NavigationEndpoint? = null,
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
        val sectionListContinuation: SectionListContinuation? = null,
    )

    @Serializable
    data class MusicShelfContinuation(
        val contents: List<MusicItemRenderer>? = null,
        val continuations: List<Continuation>? = null,
    )

    @Serializable
    data class SectionListContinuation(
        val contents: List<SectionContent>? = null,
        val continuations: List<Continuation>? = null,
    )

    @Serializable
    data class Continuation(
        val nextContinuationData: NextContinuationData? = null,
        val continuationEndpoint: ContinuationEndpoint? = null,
        val continuationCommand: ContinuationCommand? = null,
        val reloadContinuationData: ReloadContinuationData? = null,
    )

    @Serializable
    data class NextContinuationData(
        val continuation: String,
    )

    @Serializable
    data class ContinuationEndpoint(
        val continuationCommand: ContinuationCommand? = null,
    )

    @Serializable
    data class ContinuationCommand(
        val token: String? = null,
    )

    @Serializable
    data class ReloadContinuationData(
        val continuation: String? = null,
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
