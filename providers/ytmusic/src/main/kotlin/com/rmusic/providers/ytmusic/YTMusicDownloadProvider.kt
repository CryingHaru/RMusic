package com.rmusic.providers.ytmusic

import com.rmusic.providers.ytmusic.models.response.PlayerResponse
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class YTMusicDownloadProvider(
    private val api: YTMusicAPI = YTMusicAPI()
) {

    suspend fun resolveStreamingUrl(trackId: String): String? = runCatching {
        val playerResponse: PlayerResponse = api.player(trackId)

        if (playerResponse.playabilityStatus?.status != "OK") {
            throw Exception("Track not playable: ${playerResponse.playabilityStatus?.reason}")
        }

        val adaptiveFormats = playerResponse.streamingData?.adaptiveFormats
        if (adaptiveFormats.isNullOrEmpty()) {
            throw Exception("No adaptive formats found for track: $trackId")
        }

        val bestFormat = adaptiveFormats
            .filter { it.isAudio }
            .maxByOrNull { format ->
                val mime = format.mimeType.orEmpty()
                val codecScore = when {
                    mime.contains("opus", ignoreCase = true) -> 200
                    mime.contains("mp4a", ignoreCase = true) -> 150
                    else -> 0
                }
                codecScore + (format.bitrate ?: 0)
            }

        bestFormat?.url
    }.getOrNull()

    suspend fun getTrackMetadata(trackId: String): Result<TrackMetadata> = runCatching {
        val playerResponse: PlayerResponse = api.player(trackId)

        val videoDetails = playerResponse.videoDetails
        TrackMetadata(
            videoId = trackId,
            title = videoDetails?.title ?: "",
            author = videoDetails?.author ?: "",
            lengthSeconds = videoDetails?.lengthSeconds?.toLongOrNull(),
            isLiveContent = videoDetails?.isLiveContent ?: false
        )
    }

    fun downloadTrackFlow(trackId: String): Flow<DownloadResult> = flow {
        emit(DownloadResult.Progress(0f, "Resolving stream URL..."))
        
        val streamUrl = resolveStreamingUrl(trackId)
        if (streamUrl == null) {
            emit(DownloadResult.Error("Failed to resolve stream URL"))
            return@flow
        }
        
        emit(DownloadResult.Progress(0.3f, "Stream URL resolved"))
        
        val metadata = getTrackMetadata(trackId).getOrNull()
        if (metadata == null) {
            emit(DownloadResult.Error("Failed to get track metadata"))
            return@flow
        }
        
        emit(DownloadResult.Success(streamUrl, metadata))
    }

    fun close() {
        api.close()
    }
}

data class TrackMetadata(
    val videoId: String,
    val title: String,
    val author: String,
    val lengthSeconds: Long? = null,
    val isLiveContent: Boolean = false,
)

sealed class DownloadResult {
    data class Progress(val progress: Float, val message: String) : DownloadResult()
    data class Success(val streamUrl: String, val metadata: TrackMetadata) : DownloadResult()
    data class Error(val message: String) : DownloadResult()
}
