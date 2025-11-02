package com.rmusic.providers.intermusic.models.body

import com.rmusic.providers.intermusic.models.IntermusicContext
import kotlinx.serialization.Serializable

@Serializable
data class PlayerBody(
    val context: IntermusicContext,
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
    val context: IntermusicContext,
    val browseId: String? = null,
    val params: String? = null,
    val continuation: String? = null,
)

@Serializable
data class SearchBody(
    val context: IntermusicContext,
    val query: String,
    val params: String? = null,
)

@Serializable
data class NextBody(
    val context: IntermusicContext,
    val videoId: String? = null,
    val playlistId: String? = null,
    val playlistSetVideoId: String? = null,
    val index: Int? = null,
    val params: String? = null,
    val continuation: String? = null,
)
