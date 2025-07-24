package com.rmusic.download

import android.content.Context
import com.kdownloader.DownloaderConfig
import com.kdownloader.KDownloader
import com.kdownloader.Status
import com.rmusic.download.models.DownloadItem
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
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

    private val downloadIds = ConcurrentHashMap<String, Int>() // Map trackId to KDownloader downloadId
    private val activeDownloads = ConcurrentHashMap<String, DownloadItem>()

    override suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?,
        url: String
    ): Flow<DownloadState> = callbackFlow {
        try {
            trySend(DownloadState.Queued)

            val outputFileName = filename ?: "$trackId.mp3"
            val request = kDownloader.newRequestBuilder(url, outputDir, outputFileName)
                .tag(trackId)
                .build()

            val downloadId = kDownloader.enqueue(
                req = request,
                onStart = {
                    trySend(DownloadState.Downloading(0f, 0L, -1L))
                },
                onProgress = { progress ->
                    // Get file info to calculate bytes
                    val outputFile = File(outputDir, outputFileName)
                    val downloadedBytes = if (outputFile.exists()) outputFile.length() else 0L

                    trySend(
                        DownloadState.Downloading(
                            progress = progress / 100f,
                            downloadedBytes = downloadedBytes,
                            totalBytes = -1L // KDownloader doesn't provide total bytes easily
                        )
                    )
                },
                onPause = {
                    trySend(DownloadState.Paused)
                },
                onError = { error ->
                    trySend(DownloadState.Failed(Exception(error)))
                    close()
                },
                onCompleted = {
                    val outputFile = File(outputDir, outputFileName)
                    trySend(DownloadState.Completed(outputFile.absolutePath))
                    close()
                }
            )

            // Store the mapping
            downloadIds[trackId] = downloadId

        } catch (e: Exception) {
            trySend(DownloadState.Failed(e))
            close(e)
        }

        awaitClose {
            // download is either completed, failed or cancelled
            downloadIds[trackId]?.let { kDownloader.cancel(it) }
            downloadIds.remove(trackId)
        }
    }

    override suspend fun pauseDownload(downloadId: String): Result<Unit> {
        return try {
            val kDownloadId = downloadIds[downloadId]
            if (kDownloadId != null) {
                kDownloader.pause(kDownloadId)
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
                downloadIds.remove(downloadId)
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
        TODO("Not yet implemented")
    }

    override fun getAllDownloads(): Flow<List<DownloadItem>> {
        TODO("Not yet implemented")
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
