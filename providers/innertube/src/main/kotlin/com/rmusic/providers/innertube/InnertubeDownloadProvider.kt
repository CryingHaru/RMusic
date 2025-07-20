package com.rmusic.providers.innertube

import com.rmusic.providers.innertube.models.bodies.PlayerBody
import com.rmusic.providers.innertube.requests.player
import com.rmusic.providers.utils.runCatchingCancellable
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

/**
 * Download provider that handles YouTube Music URLs
 * by resolving them through Innertube APIs before downloading
 */
class InnertubeDownloadProvider(
    private val innertube: Innertube = Innertube
) {

    /**
     * Downloads a track by first resolving the streaming URL through Innertube
     */
    suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?
    ): String? {
        return try {
            // Resolve streaming URL using Innertube player API
            resolveStreamingUrl(trackId)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Resolves streaming URL for a given track ID using Innertube player API
     */
    private suspend fun resolveStreamingUrl(trackId: String): String? = runCatchingCancellable {
        val playerBody = PlayerBody(videoId = trackId)
        val playerResponse = innertube.player(playerBody)?.getOrNull()
        
        if (playerResponse == null) {
            throw Exception("Failed to get player response for track: $trackId")
        }
        
        // Get the best audio format (prefer 251 itag for AAC or 140 for M4A, fallback to highest bitrate)
        val adaptiveFormats = playerResponse.streamingData?.adaptiveFormats
        if (adaptiveFormats.isNullOrEmpty()) {
            throw Exception("No adaptive formats found for track: $trackId")
        }
        
        val bestFormat = adaptiveFormats
            .filter { it.mimeType.startsWith("audio/") }
            .run {
                // Prefer AAC 251 or M4A 140
                find { it.itag == 251 || it.itag == 140 } 
                    ?: maxByOrNull { it.bitrate ?: 0L }
            }
        
        if (bestFormat == null) {
            throw Exception("No suitable audio format found for track: $trackId")
        }
        
        // Resolve URL (handle signature cipher if needed)
        bestFormat.findUrl(playerResponse.context!!)
            ?: throw Exception("Failed to resolve download URL for track: $trackId")
            
    }?.onFailure { 
        it.printStackTrace() 
    }?.getOrNull()

}
