package com.rmusic.providers.ytmusic.models.body

import com.rmusic.providers.ytmusic.models.YTMusicContext
import kotlinx.serialization.Serializable

@Serializable
data class AccountMenuBody(
    val context: YTMusicContext,
    val deviceTheme: String = "DEVICE_THEME_SELECTED",
    val userInterfaceTheme: String = "USER_INTERFACE_THEME_DARK",
)

@Serializable
data class LikeBody(
    val context: YTMusicContext,
    val target: Target,
) {
    @Serializable
    data class Target(
        val videoId: String,
    )
}

@Serializable
data class CreatePlaylistBody(
    val context: YTMusicContext,
    val title: String,
    val description: String? = null,
    val privacyStatus: String = "PRIVATE",
    val videoIds: List<String>? = null,
)

@Serializable
data class EditPlaylistBody(
    val context: YTMusicContext,
    val playlistId: String,
    val title: String? = null,
    val description: String? = null,
    val privacyStatus: String? = null,
)

@Serializable
data class AddPlaylistItemBody(
    val context: YTMusicContext,
    val playlistId: String,
    val actions: List<Action>,
) {
    @Serializable
    data class Action(
        val action: String = "ACTION_ADD_VIDEO",
        val addedVideoId: String,
    )
}

@Serializable
data class RemovePlaylistItemBody(
    val context: YTMusicContext,
    val playlistId: String,
    val actions: List<Action>,
) {
    @Serializable
    data class Action(
        val action: String = "ACTION_REMOVE_VIDEO",
        val removedVideoId: String,
        val setVideoId: String? = null,
    )
}
