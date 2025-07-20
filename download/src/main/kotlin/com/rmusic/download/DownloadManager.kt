package com.rmusic.download

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import com.rmusic.download.DownloadProvider
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.collect
import com.rmusic.download.models.DownloadItem
import com.rmusic.download.DownloadState
import kotlinx.coroutines.launch
import java.io.File
import java.util.concurrent.ConcurrentHashMap

/**
 * Manages downloads across different providers and handles the download queue
 */
class DownloadManager(
    private val downloadDir: File,
    private val providers: Map<String, DownloadProvider>
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    
    private val _downloads = MutableStateFlow<Map<String, DownloadItem>>(emptyMap<String, DownloadItem>())
    val downloads: StateFlow<Map<String, DownloadItem>> = _downloads.asStateFlow()
    
    private val activeDownloads = ConcurrentHashMap<String, DownloadProvider>()
    
    init {
        // Ensure download directory exists
        downloadDir.mkdirs()
    }
    
    /**
     * Starts downloading a track
     */
    suspend fun downloadTrack(
        providerId: String,
        trackId: String,
        title: String,
        artist: String? = null,
        album: String? = null,
        thumbnailUrl: String? = null,
        duration: Long? = null,
        url: String
    ) {
        val provider = providers[providerId] ?: throw IllegalArgumentException("Unknown provider: $providerId")
        
        // Create organized directory structure: Artist/Album/
        val artistDir = File(downloadDir, sanitizeFilename(artist ?: "Unknown Artist"))
        val albumDir = File(artistDir, sanitizeFilename(album ?: "Unknown Album"))
        albumDir.mkdirs()
        
        val filename = "${sanitizeFilename(title)}.mp3"
        val filePath = File(albumDir, filename).absolutePath
        
        val downloadItem = DownloadItem(
            id = trackId,
            title = title,
            artist = artist,
            album = album,
            thumbnailUrl = thumbnailUrl,
            duration = duration,
            url = url,
            filePath = filePath,
            state = DownloadState.Queued
        )
        
        // Add to downloads map
        _downloads.value = _downloads.value + (trackId to downloadItem)
        activeDownloads[trackId] = provider
        
        // Create and start the download flow
        val downloadFlow = if (provider is HttpDownloadProvider) {
            provider.downloadTrackWithUrl(trackId, albumDir.absolutePath, filename, url)
        } else {
            provider.downloadTrack(trackId, albumDir.absolutePath, filename)
        }
        
        // Launch a coroutine to monitor the download and update state
        scope.launch {
            downloadFlow.collect { state ->
                updateDownloadState(trackId, state)
                
                // Remove from active downloads when completed, failed, or cancelled
                when (state) {
                    is DownloadState.Completed,
                    is DownloadState.Failed,
                    is DownloadState.Cancelled -> {
                        activeDownloads.remove(trackId)
                    }
                    else -> {}
                }
            }
        }
    }
    
    /**
     * Pauses a download
     */
    suspend fun pauseDownload(trackId: String) {
        val provider = activeDownloads[trackId]
        provider?.pauseDownload(trackId)
    }

    /**
     * Resumes a download
     */
    suspend fun resumeDownload(trackId: String) {
        val provider = activeDownloads[trackId]
        provider?.resumeDownload(trackId)
    }

    /**
     * Cancels a download
     */
    suspend fun cancelDownload(trackId: String) {
        val provider = activeDownloads[trackId]
        provider?.cancelDownload(trackId)
        
        // Immediately update the state to cancelled and remove from active
        updateDownloadState(trackId, DownloadState.Cancelled)
        activeDownloads.remove(trackId)
        _downloads.value = _downloads.value - trackId
    }
    
    /**
     * Deletes a downloaded file
     */
    fun deleteDownload(trackId: String): Result<Unit> {
        val download = _downloads.value[trackId] ?: return Result.failure(
            IllegalStateException("Download not found: $trackId")
        )
        
        return try {
            val file = File(download.filePath)
            if (file.exists() && file.delete()) {
                _downloads.value = _downloads.value - trackId
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to delete file"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Gets downloads organized by artist and album (Apple Music style)
     */
    fun getDownloadsGrouped(): Flow<Map<String, Map<String, List<DownloadItem>>>> {
        return downloads.map { downloadsMap ->
            downloadsMap.values
                .filter { it.state is DownloadState.Completed }
                .groupBy { it.artist ?: "Unknown Artist" }
                .mapValues { (_, songs) ->
                    songs.groupBy { it.album ?: "Unknown Album" }
                }
        }
    }
    
    /**
     * Gets all completed downloads
     */
    fun getCompletedDownloads(): Flow<List<DownloadItem>> {
        return downloads.map { downloadsMap ->
            downloadsMap.values.filter { it.state is DownloadState.Completed }
        }
    }
    
    /**
     * Gets download progress for active downloads
     */
    fun getActiveDownloads(): Flow<List<DownloadItem>> {
        return downloads.map { downloadsMap ->
            downloadsMap.values.filter { 
                it.state is DownloadState.Downloading || 
                it.state is DownloadState.Queued || 
                it.state is DownloadState.Paused 
            }
        }
    }
    
    /**
     * Enhanced error handling with retry mechanisms
     */
    private suspend fun handleDownloadFailure(
        downloadItem: DownloadItem,
        error: Throwable
    ) {
        android.util.Log.e("DownloadManager", "Download failed for ${downloadItem.title}", error)
        
        // Update download item with failed state
        val failedState = if (error is Exception && error.message?.contains("retryable") == true) {
            DownloadState.Failed(error, isRetryable = true)
        } else {
            DownloadState.Failed(error, isRetryable = false)
        }
        
        val updatedItem = downloadItem.copy(state = failedState)
        updateDownloadItem(updatedItem)
        
        // Clean up resources
        activeDownloads.remove(downloadItem.id)
        
        // Log detailed error information for debugging
        when {
            error is java.net.UnknownHostException -> {
                android.util.Log.w("DownloadManager", "Network connectivity issue for ${downloadItem.title}")
            }
            error is java.net.SocketTimeoutException -> {
                android.util.Log.w("DownloadManager", "Download timeout for ${downloadItem.title}")
            }
            error.message?.contains("403") == true -> {
                android.util.Log.e("DownloadManager", "Access forbidden for ${downloadItem.title}")
            }
            error.message?.contains("404") == true -> {
                android.util.Log.e("DownloadManager", "Resource not found for ${downloadItem.title}")
            }
            else -> {
                android.util.Log.e("DownloadManager", "Unknown error for ${downloadItem.title}: ${error.message}")
            }
        }
    }
    
    /**
     * Updates download item in the state flow
     */
    private fun updateDownloadItem(downloadItem: DownloadItem) {
        val currentDownloads = _downloads.value.toMutableMap()
        currentDownloads[downloadItem.id] = downloadItem
        _downloads.value = currentDownloads
    }
    
    private fun updateDownloadState(trackId: String, state: DownloadState) {
        val currentDownload = _downloads.value[trackId] ?: return
        val updatedDownload = currentDownload.copy(state = state)
        _downloads.value = _downloads.value + (trackId to updatedDownload)
    }
    
    private fun sanitizeFilename(name: String): String {
        return name.replace(Regex("[<>:\"/\\\\|?*]"), "_").trim()
    }
}
