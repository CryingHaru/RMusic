package com.rmusic.providers.intermusic.parser

import com.rmusic.providers.intermusic.models.response.BrowseResponse
import com.rmusic.providers.intermusic.models.response.LibraryResponse
import com.rmusic.providers.intermusic.models.response.PlayerResponse
import com.rmusic.providers.intermusic.pages.AlbumItem
import com.rmusic.providers.intermusic.pages.AlbumResult
import com.rmusic.providers.intermusic.pages.ArtistItem
import com.rmusic.providers.intermusic.pages.ArtistResult
import com.rmusic.providers.intermusic.pages.AudioFormat
import com.rmusic.providers.intermusic.pages.PlaylistItem
import com.rmusic.providers.intermusic.pages.PlaylistResult
import com.rmusic.providers.intermusic.pages.SearchResult
import com.rmusic.providers.intermusic.pages.SongItem
import com.rmusic.providers.intermusic.pages.SongResult
import com.rmusic.providers.intermusic.pages.StreamingData
import com.rmusic.providers.intermusic.pages.Thumbnail
import com.rmusic.providers.intermusic.pages.VideoItem
import com.rmusic.providers.intermusic.models.account.LibraryPlaylist
import com.rmusic.providers.intermusic.models.account.PlaylistPrivacy

fun parseSearchResults(response: BrowseResponse): SearchResult {
    val songs = mutableListOf<SongItem>()
    val albums = mutableListOf<AlbumItem>()
    val artists = mutableListOf<ArtistItem>()
    val playlists = mutableListOf<PlaylistItem>()
    val videos = mutableListOf<VideoItem>()

    response.contents?.singleColumnBrowseResultsRenderer?.tabs?.firstOrNull()
        ?.tabRenderer?.content?.sectionListRenderer?.contents?.forEach { section ->
            section.musicShelfRenderer?.contents?.forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    parseSearchItem(renderer, songs, albums, artists, playlists, videos)
                }
            }
            section.musicCarouselShelfRenderer?.contents?.forEach { item ->
                item.musicTwoRowItemRenderer?.let { renderer ->
                    parseCarouselItem(renderer, albums, artists, playlists)
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

fun parseAlbumPage(response: BrowseResponse): AlbumResult {
    val header = response.header?.musicDetailHeaderRenderer
    val tracks = mutableListOf<SongItem>()

    response.contents?.singleColumnBrowseResultsRenderer?.tabs?.firstOrNull()
        ?.tabRenderer?.content?.sectionListRenderer?.contents?.forEach { section ->
            section.musicShelfRenderer?.contents?.forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    parseTrackItem(renderer)?.let { track ->
                        tracks.add(track)
                    }
                }
            }
        }

    return AlbumResult(
        id = "",
        title = header?.title?.runs?.firstOrNull()?.text ?: "",
        description = header?.subtitle?.runs?.joinToString(" ") { it.text },
        thumbnails = header?.thumbnail?.thumbnails?.map { 
            Thumbnail(it.url, it.width, it.height) 
        } ?: emptyList(),
        tracks = tracks
    )
}

fun parseArtistPage(response: BrowseResponse): ArtistResult {
    val header = response.header?.musicDetailHeaderRenderer
    val songs = mutableListOf<SongItem>()
    val albums = mutableListOf<AlbumItem>()

    response.contents?.singleColumnBrowseResultsRenderer?.tabs?.firstOrNull()
        ?.tabRenderer?.content?.sectionListRenderer?.contents?.forEach { section ->
            section.musicShelfRenderer?.contents?.forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    parseTrackItem(renderer)?.let { track ->
                        songs.add(track)
                    }
                }
            }
            section.musicCarouselShelfRenderer?.contents?.forEach { item ->
                item.musicTwoRowItemRenderer?.let { renderer ->
                    parseAlbumCarouselItem(renderer)?.let { album ->
                        albums.add(album)
                    }
                }
            }
        }

    return ArtistResult(
        id = "",
        name = header?.title?.runs?.firstOrNull()?.text ?: "",
        description = header?.subtitle?.runs?.joinToString(" ") { it.text },
        thumbnails = header?.thumbnail?.thumbnails?.map { 
            Thumbnail(it.url, it.width, it.height) 
        } ?: emptyList(),
        songs = songs,
        albums = albums,
        singles = emptyList(),
        videos = emptyList()
    )
}

fun parsePlaylistPage(response: BrowseResponse): PlaylistResult {
    val header = response.header?.musicDetailHeaderRenderer
    val tracks = mutableListOf<SongItem>()

    response.contents?.singleColumnBrowseResultsRenderer?.tabs?.firstOrNull()
        ?.tabRenderer?.content?.sectionListRenderer?.contents?.forEach { section ->
            section.musicShelfRenderer?.contents?.forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    parseTrackItem(renderer)?.let { track ->
                        tracks.add(track)
                    }
                }
            }
        }

    return PlaylistResult(
        id = "",
        title = header?.title?.runs?.firstOrNull()?.text ?: "",
        description = header?.subtitle?.runs?.joinToString(" ") { it.text },
        thumbnails = header?.thumbnail?.thumbnails?.map { 
            Thumbnail(it.url, it.width, it.height) 
        } ?: emptyList(),
        tracks = tracks
    )
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

private fun parseSearchItem(
    renderer: BrowseResponse.MusicResponsiveListItemRenderer,
    songs: MutableList<SongItem>,
    albums: MutableList<AlbumItem>,
    artists: MutableList<ArtistItem>,
    playlists: MutableList<PlaylistItem>,
    videos: MutableList<VideoItem>
) {
    val videoId = renderer.playNavigationEndpoint?.watchEndpoint?.videoId
    if (videoId != null) {
        parseTrackItem(renderer)?.let { songs.add(it) }
        return
    }

    val browseId = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId
    if (browseId != null) {
        when {
            browseId.startsWith("MPRE") -> parseAlbumItem(renderer)?.let { albums.add(it) }
            browseId.startsWith("UC") -> parseArtistItem(renderer)?.let { artists.add(it) }
            browseId.startsWith("VL") -> parsePlaylistItem(renderer)?.let { playlists.add(it) }
        }
    }
}

private fun parseCarouselItem(
    renderer: BrowseResponse.MusicTwoRowItemRenderer,
    albums: MutableList<AlbumItem>,
    artists: MutableList<ArtistItem>,
    playlists: MutableList<PlaylistItem>
) {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId
    if (browseId != null) {
        when {
            browseId.startsWith("MPRE") -> parseAlbumCarouselItem(renderer)?.let { albums.add(it) }
            browseId.startsWith("UC") -> parseArtistCarouselItem(renderer)?.let { artists.add(it) }
            browseId.startsWith("VL") -> parsePlaylistCarouselItem(renderer)?.let { playlists.add(it) }
        }
    }
}

private fun parseTrackItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): SongItem? {
    val videoId = renderer.playNavigationEndpoint?.watchEndpoint?.videoId ?: return null
    val title = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.text ?: ""
    
    val artists = renderer.flexColumns?.getOrNull(1)?.text?.runs
        ?.filter { it.navigationEndpoint?.browseEndpoint != null }
        ?.map { run ->
            ArtistItem(
                browseId = run.navigationEndpoint?.browseEndpoint?.browseId,
                name = run.text
            )
        } ?: emptyList()

    return SongItem(
        videoId = videoId,
        title = title,
        artists = artists
    )
}

private fun parseAlbumItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): AlbumItem? {
    val browseId = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.text ?: ""
    
    return AlbumItem(
        browseId = browseId,
        title = title
    )
}

private fun parseArtistItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): ArtistItem? {
    val browseId = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val name = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.text ?: ""
    
    return ArtistItem(
        browseId = browseId,
        name = name
    )
}

private fun parsePlaylistItem(renderer: BrowseResponse.MusicResponsiveListItemRenderer): PlaylistItem? {
    val browseId = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.text ?: ""
    
    return PlaylistItem(
        browseId = browseId,
        title = title
    )
}

private fun parseAlbumCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): AlbumItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.title?.runs?.firstOrNull()?.text ?: ""
    
    val thumbnails = renderer.thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails?.map {
        Thumbnail(it.url, it.width, it.height)
    } ?: emptyList()

    return AlbumItem(
        browseId = browseId,
        title = title,
        thumbnails = thumbnails
    )
}

private fun parseArtistCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): ArtistItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val name = renderer.title?.runs?.firstOrNull()?.text ?: ""
    
    val thumbnails = renderer.thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails?.map {
        Thumbnail(it.url, it.width, it.height)
    } ?: emptyList()

    return ArtistItem(
        browseId = browseId,
        name = name,
        thumbnails = thumbnails
    )
}

private fun parsePlaylistCarouselItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): PlaylistItem? {
    val browseId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.title?.runs?.firstOrNull()?.text ?: ""
    
    val thumbnails = renderer.thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails?.map {
        Thumbnail(it.url, it.width, it.height)
    } ?: emptyList()

    return PlaylistItem(
        browseId = browseId,
        title = title,
        thumbnails = thumbnails
    )
}

fun parseLibraryPlaylists(response: LibraryResponse): List<LibraryPlaylist> {
    val playlists = mutableListOf<LibraryPlaylist>()
    
    response.contents?.singleColumnBrowseResultsRenderer?.tabs?.firstOrNull()
        ?.tabRenderer?.content?.sectionListRenderer?.contents?.forEach { section ->
            
            section.gridRenderer?.items?.forEach { item ->
                item.musicTwoRowItemRenderer?.let { renderer ->
                    parseLibraryPlaylistItem(renderer)?.let { playlist ->
                        playlists.add(playlist)
                    }
                }
            }
            
            
            section.musicShelfRenderer?.contents?.forEach { item ->
                item.musicResponsiveListItemRenderer?.let { renderer ->
                    parseLibraryPlaylistFromList(renderer)?.let { playlist ->
                        playlists.add(playlist)
                    }
                }
            }
        }
    
    return playlists
}

private fun parseLibraryPlaylistItem(renderer: BrowseResponse.MusicTwoRowItemRenderer): LibraryPlaylist? {
    val playlistId = renderer.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.title?.runs?.firstOrNull()?.text ?: return null
    
    val thumbnails = renderer.thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails?.map {
        Thumbnail(it.url, it.width, it.height)
    } ?: emptyList()
    
    
    val subtitle = renderer.subtitle?.runs?.joinToString(" ") { it.text } ?: ""
    val trackCount = subtitle.filter { it.isDigit() }.toIntOrNull()
    
    return LibraryPlaylist(
        playlistId = playlistId,
        title = title,
        thumbnails = thumbnails,
        trackCount = trackCount,
        privacy = PlaylistPrivacy.PRIVATE 
    )
}

private fun parseLibraryPlaylistFromList(renderer: BrowseResponse.MusicResponsiveListItemRenderer): LibraryPlaylist? {
    val playlistId = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()
        ?.navigationEndpoint?.browseEndpoint?.browseId ?: return null
    val title = renderer.flexColumns?.firstOrNull()?.text?.runs?.firstOrNull()?.text ?: return null
    
    
    val trackCountText = renderer.flexColumns?.getOrNull(1)?.text?.runs?.firstOrNull()?.text ?: ""
    val trackCount = trackCountText.filter { it.isDigit() }.toIntOrNull()
    
    return LibraryPlaylist(
        playlistId = playlistId,
        title = title,
        trackCount = trackCount,
        privacy = PlaylistPrivacy.PRIVATE
    )
}
