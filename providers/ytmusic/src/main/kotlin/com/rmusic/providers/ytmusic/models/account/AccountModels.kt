package com.rmusic.providers.ytmusic.models.account

import com.rmusic.providers.ytmusic.pages.Thumbnail
import kotlinx.serialization.Serializable

@Serializable
data class AccountInfo(
    val name: String,
    val email: String,
    val channelId: String,
    val thumbnails: List<Thumbnail> = emptyList(),
    val isLoggedIn: Boolean = true,
)

@Serializable
data class LibraryPlaylist(
    val playlistId: String,
    val title: String,
    val description: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val trackCount: Int? = null,
    val privacy: PlaylistPrivacy = PlaylistPrivacy.PRIVATE,
    val isOwnedByUser: Boolean = true,
)

@Serializable
data class LikedSongsInfo(
    val trackCount: Int,
    val lastUpdated: String? = null,
)

enum class PlaylistPrivacy {
    PUBLIC,
    UNLISTED,
    PRIVATE
}

@Serializable
data class LoginCredentials(
    val cookie: String,
    val visitorData: String? = null,
    val sessionToken: String? = null,
    val dataSyncId: String? = null,
    val poToken: String? = null,
    val sapisidHash: String? = null,
    
    val authorization: String? = null,
    val xGoogAuthUser: String? = null,
    val xGoogVisitorId: String? = null,
    val clientHints: Map<String,String>? = null,
    val extraHeaders: Map<String,String>? = null,
)

@Serializable
data class LoginResult(
    val success: Boolean,
    val accountInfo: AccountInfo? = null,
    val error: String? = null,
    val requiresVerification: Boolean = false,
    val sessionData: SessionData? = null,
)

@Serializable
data class SessionData(
    val visitorData: String,
    val dataSyncId: String? = null,
    val poToken: String? = null,
    val poTokenExpiry: Long? = null,
    val sapisidHash: String? = null,
    val sessionId: String? = null,
    val authorization: String? = null,
    val xGoogAuthUser: String? = null,
    val xGoogVisitorId: String? = null,
    val clientHints: Map<String,String>? = null,
    val extraHeaders: Map<String,String>? = null,
)

@Serializable
data class AuthenticationState(
    val isLoggedIn: Boolean = false,
    val credentials: LoginCredentials? = null,
    val sessionData: SessionData? = null,
    val lastRefresh: Long = 0L,
    val tokenExpiry: Long = 0L,
)

@Serializable
data class TokenRefreshResult(
    val success: Boolean,
    val newPoToken: String? = null,
    val newSapisidHash: String? = null,
    val expiryTime: Long? = null,
    val error: String? = null,
)
