package com.rmusic.download

import kotlinx.coroutines.flow.Flow
import com.rmusic.download.DownloadState
import com.rmusic.download.models.DownloadItem

/**
 * Defines the interface for download providers used by DownloadManager.
 */
interface DownloadProvider {
    suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?,
        url: String
    ): Flow<DownloadState>

    suspend fun pauseDownload(downloadId: String): Result<Unit>
    suspend fun resumeDownload(downloadId: String): Result<Unit>
    suspend fun cancelDownload(downloadId: String): Result<Unit>

    fun getDownloadState(downloadId: String): Flow<DownloadState>
    fun getAllDownloads(): Flow<List<DownloadItem>>
}
