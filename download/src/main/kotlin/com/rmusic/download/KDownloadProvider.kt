package com.rmusic.download

import android.content.Context
import com.kdownloader.DownloaderConfig
import com.kdownloader.KDownloader
import com.kdownloader.Status
import com.rmusic.download.models.DownloadItem
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.File
import java.util.concurrent.ConcurrentHashMap

/**
 * KDownloader-based download provider implementation with pause/resume support
 */
class KDownloadProvider(
    private val context: Context
) : DownloadProvider {

    private val kDownloader: KDownloader = KDownloader.create(
        context = context,
        config = DownloaderConfig(
            databaseEnabled = true,
            readTimeOut = 60000,
            connectTimeOut = 30000
        )
    )

    private val downloadStates = ConcurrentHashMap<String, MutableStateFlow<DownloadState>>()
    private val downloadIds = ConcurrentHashMap<String, Int>() // Map trackId to KDownloader downloadId
    private val activeDownloads = ConcurrentHashMap<String, DownloadItem>()

    override suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?,
        url: String
    ): Flow<DownloadState> = flow {
        val stateFlow = downloadStates.getOrPut(trackId) {
            MutableStateFlow(DownloadState.Queued)
        }

        try {
            emit(DownloadState.Queued)
            stateFlow.value = DownloadState.Queued

            val outputFileName = filename ?: "$trackId.mp3"
            val request = kDownloader.newRequestBuilder(url, outputDir, outputFileName)
                .tag(trackId)
                .build()

            val downloadId = kDownloader.enqueue(
                req = request,
                onStart = {
                    val startedState = DownloadState.Downloading(0f, 0L, -1L)
                    stateFlow.value = startedState
                },
                onProgress = { progress ->
                    // Get file info to calculate bytes
                    val outputFile = File(outputDir, outputFileName)
                    val downloadedBytes = if (outputFile.exists()) outputFile.length() else 0L
                    
                    val downloadingState = DownloadState.Downloading(
                        progress = progress / 100f,
                        downloadedBytes = downloadedBytes,
                        totalBytes = -1L // KDownloader doesn't provide total bytes easily
                    )
                    stateFlow.value = downloadingState
                },
                onPause = {
                    stateFlow.value = DownloadState.Paused
                },
                onError = { error ->
                    val failedState = DownloadState.Failed(Exception(error))
                    stateFlow.value = failedState
                },
                onCompleted = {
                    val outputFile = File(outputDir, outputFileName)
                    val completedState = DownloadState.Completed(outputFile.absolutePath)
                    stateFlow.value = completedState
                }
            )

            // Store the mapping
            downloadIds[trackId] = downloadId

            // Collect state changes from the state flow
            stateFlow.collect { state ->
                emit(state)
            }

        } catch (e: Exception) {
            val failedState = DownloadState.Failed(e)
            emit(failedState)
            stateFlow.value = failedState
        }
    }

    override suspend fun pauseDownload(downloadId: String): Result<Unit> {
        return try {
            val kDownloadId = downloadIds[downloadId]
            if (kDownloadId != null) {
                kDownloader.pause(kDownloadId)
                downloadStates[downloadId]?.value = DownloadState.Paused
                Result.success(Unit)
            } else {
                Result.failure(IllegalStateException("Download ID not found: $downloadId"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun resumeDownload(downloadId: String): Result<Unit> {
        return try {
            val kDownloadId = downloadIds[downloadId]
            if (kDownloadId != null) {
                kDownloader.resume(kDownloadId)
                Result.success(Unit)
            } else {
                Result.failure(IllegalStateException("Download ID not found: $downloadId"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun cancelDownload(downloadId: String): Result<Unit> {
        return try {
            val kDownloadId = downloadIds[downloadId]
            if (kDownloadId != null) {
                kDownloader.cancel(kDownloadId)
                downloadStates[downloadId]?.value = DownloadState.Cancelled
                downloadIds.remove(downloadId)
                downloadStates.remove(downloadId)
                activeDownloads.remove(downloadId)
                Result.success(Unit)
            } else {
                Result.failure(IllegalStateException("Download ID not found: $downloadId"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun getDownloadState(downloadId: String): Flow<DownloadState> {
        return downloadStates[downloadId]?.asStateFlow() ?: flow {
            emit(DownloadState.Failed(Exception("Download not found")))
        }
    }

    override fun getAllDownloads(): Flow<List<DownloadItem>> {
        return flow { 
            emit(activeDownloads.values.toList())
        }
    }

    /**
     * Get KDownloader status for a specific download
     */
    fun getKDownloaderStatus(trackId: String): Status? {
        val kDownloadId = downloadIds[trackId]
        return if (kDownloadId != null) {
            kDownloader.status(kDownloadId)
        } else null
    }

    /**
     * Cancel all downloads
     */
    fun cancelAllDownloads() {
        kDownloader.cancelAll()
        downloadStates.clear()
        downloadIds.clear()
        activeDownloads.clear()
    }

    /**
     * Clean up old resumed files
     */
    fun cleanUp(days: Int) {
        kDownloader.cleanUp(days)
    }
}
