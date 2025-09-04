package com.rmusic.providers.ytmusic.models.body

import com.rmusic.providers.ytmusic.models.YTMusicContext
import kotlinx.serialization.Serializable

@Serializable
data class PlayerBody(
    val context: YTMusicContext,
    val videoId: String,
    val playlistId: String? = null,
    val cpn: String? = null,
    val playbackContext: PlaybackContext? = null,
    val serviceIntegrityDimensions: ServiceIntegrityDimensions? = null,
    
    val contentCheckOk: Boolean = true,
    val racyCheckOk: Boolean = true,
) {
    @Serializable
    data class PlaybackContext(
        val contentPlaybackContext: ContentPlaybackContext = ContentPlaybackContext(),
    )

    @Serializable
    data class ContentPlaybackContext(
        val signatureTimestamp: String? = null,
    )

    @Serializable
    data class ServiceIntegrityDimensions(
        val poToken: String? = null,
    )
}

@Serializable
data class BrowseBody(
    val context: YTMusicContext,
    val browseId: String? = null,
    val params: String? = null,
    val continuation: String? = null,
)

@Serializable
data class SearchBody(
    val context: YTMusicContext,
    val query: String,
    val params: String? = null,
)

@Serializable
data class NextBody(
    val context: YTMusicContext,
    val videoId: String? = null,
    val playlistId: String? = null,
    val playlistSetVideoId: String? = null,
    val index: Int? = null,
    val params: String? = null,
    val continuation: String? = null,
)
