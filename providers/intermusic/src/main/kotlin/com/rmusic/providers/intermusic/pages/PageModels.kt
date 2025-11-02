package com.rmusic.providers.intermusic.pages

import kotlinx.serialization.Serializable

data class SearchResult(
    val songs: List<SongItem> = emptyList(),
    val albums: List<AlbumItem> = emptyList(),
    val artists: List<ArtistItem> = emptyList(),
    val playlists: List<PlaylistItem> = emptyList(),
    val videos: List<VideoItem> = emptyList(),
)

data class AlbumResult(
    val id: String,
    val title: String,
    val description: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val year: String? = null,
    val artists: List<ArtistItem> = emptyList(),
    val tracks: List<SongItem> = emptyList(),
)

data class ArtistResult(
    val id: String,
    val name: String,
    val description: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val subscribers: String? = null,
    val songs: List<SongItem> = emptyList(),
    val albums: List<AlbumItem> = emptyList(),
    val singles: List<AlbumItem> = emptyList(),
    val videos: List<VideoItem> = emptyList(),
)

data class PlaylistResult(
    val id: String,
    val title: String,
    val description: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val author: String? = null,
    val year: String? = null,
    val trackCount: Int? = null,
    val tracks: List<SongItem> = emptyList(),
)

data class SongResult(
    val videoId: String,
    val title: String? = null,
    val artists: List<ArtistItem> = emptyList(),
    val album: AlbumItem? = null,
    val duration: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val streamingData: StreamingData? = null,
)

data class SongItem(
    val videoId: String,
    val title: String,
    val artists: List<ArtistItem> = emptyList(),
    val album: AlbumItem? = null,
    val duration: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val explicit: Boolean = false,
)

data class AlbumItem(
    val browseId: String,
    val title: String,
    val artists: List<ArtistItem> = emptyList(),
    val year: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
    val explicit: Boolean = false,
)

data class ArtistItem(
    val browseId: String? = null,
    val name: String,
    val thumbnails: List<Thumbnail> = emptyList(),
)

data class PlaylistItem(
    val browseId: String,
    val title: String,
    val author: String? = null,
    val songCount: Int? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
)

data class VideoItem(
    val videoId: String,
    val title: String,
    val author: String? = null,
    val duration: String? = null,
    val viewCount: String? = null,
    val thumbnails: List<Thumbnail> = emptyList(),
)

@Serializable
data class Thumbnail(
    
    val url: String = "",
    val width: Int? = null,
    val height: Int? = null,
)

data class StreamingData(
    val formats: List<AudioFormat> = emptyList(),
    val expiresInSeconds: String? = null,
)

data class AudioFormat(
    val itag: Int,
    val url: String? = null,
    val mimeType: String? = null,
    val bitrate: Int? = null,
    val contentLength: String? = null,
    val quality: String? = null,
    val audioQuality: String? = null,
    val audioSampleRate: String? = null,
    val audioChannels: Int? = null,
)
