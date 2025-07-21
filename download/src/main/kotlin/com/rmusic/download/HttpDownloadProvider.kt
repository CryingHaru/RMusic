package com.rmusic.download

import io.ktor.client.HttpClient
import io.ktor.client.request.get
import io.ktor.client.request.headers
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsChannel
import io.ktor.http.isSuccess
import io.ktor.utils.io.readAvailable
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.pow

/**
 * Basic HTTP-based download provider implementation
 */
class HttpDownloadProvider(
    private val httpClient: HttpClient
) : DownloadProvider {

    private val downloadStates = ConcurrentHashMap<String, MutableStateFlow<DownloadState>>()
    private val downloadTasks = ConcurrentHashMap<String, Boolean>() // Track if download should continue
    private val downloadMetadata = ConcurrentHashMap<String, DownloadMetadata>() // Track download info for resume

    /**
     * Internal class to track download metadata for resume functionality
     */
    private data class DownloadMetadata(
        val trackId: String,
        val url: String,
        val outputDir: String,
        val filename: String?,
        val totalBytes: Long = -1L,
        val downloadedBytes: Long = 0L
    )

    override suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?,
        url: String
    ): Flow<DownloadState> = flow {
        val stateFlow = downloadStates.getOrPut(trackId) {
            MutableStateFlow(DownloadState.Queued)
        }

        downloadTasks[trackId] = true

        try {
            emit(DownloadState.Queued)
            stateFlow.value = DownloadState.Queued

            val outputFile = File(outputDir, filename ?: "$trackId.mp3")

            // Store metadata for potential resume
            val metadata = DownloadMetadata(
                trackId = trackId,
                url = url,
                outputDir = outputDir,
                filename = filename
            )
            downloadMetadata[trackId] = metadata

            var response: HttpResponse
            var contentLength = -1L
            var retries = 0
            val maxRetries = 3

            while (true) {
                try {
                    response = httpClient.get(url)
                    contentLength = response.headers["Content-Length"]?.toLongOrNull() ?: -1L
                    break
                } catch (e: Exception) {
                    retries++
                    android.util.Log.w("HttpDownloadProvider", "HTTP request failed for $trackId, attempt $retries", e)

                    if (retries >= maxRetries) {
                        val error = Exception("Failed to download $trackId after $retries attempts", e)
                        emit(DownloadState.Failed(error, isRetryable = false))
                        stateFlow.value = DownloadState.Failed(error, isRetryable = false)
                        return@flow
                    }

                    // Exponential backoff
                    val delayTime = (1000L * 2.0.pow(retries)).toLong()
                    android.util.Log.d("HttpDownloadProvider", "Retrying in ${delayTime}ms")
                    delay(delayTime)
                }
            }

            if (!response.status.isSuccess()) {
                val error = Exception("HTTP ${response.status.value}: ${response.status.description}")
                emit(DownloadState.Failed(error))
                stateFlow.value = DownloadState.Failed(error)
                return@flow
            }

            val channel = response.bodyAsChannel()

            // Update metadata with total bytes
            downloadMetadata[trackId] = metadata.copy(totalBytes = contentLength)

            outputFile.parentFile?.mkdirs()

            try {
                val startedState = DownloadState.Downloading(0f, 0L, contentLength)
                emit(startedState)
                stateFlow.value = startedState

                outputFile.outputStream().use { outputStream ->
                    var totalBytesRead = 0L
                    val buffer = ByteArray(8192)

                    while (!channel.isClosedForRead && downloadTasks[trackId] == true) {
                        val bytesRead = channel.readAvailable(buffer)
                        if (bytesRead <= 0) {
                            if (channel.isClosedForRead) break
                            delay(10) // Avoid busy waiting
                            continue
                        }

                        outputStream.write(buffer, 0, bytesRead)
                        totalBytesRead += bytesRead

                        downloadMetadata[trackId] = downloadMetadata[trackId]?.copy(
                            downloadedBytes = totalBytesRead
                        ) ?: metadata.copy(downloadedBytes = totalBytesRead)

                        val progress = if (contentLength > 0) {
                            (totalBytesRead.toFloat() / contentLength.toFloat()).coerceIn(0f, 1f)
                        } else -1f

                        val downloadingState = DownloadState.Downloading(progress, totalBytesRead, contentLength)
                        emit(downloadingState)
                        stateFlow.value = downloadingState
                    }
                }

                if (downloadTasks[trackId] != true) {
                    outputFile.delete()
                    emit(DownloadState.Cancelled)
                    stateFlow.value = DownloadState.Cancelled
                    return@flow
                }

                if (outputFile.exists() && outputFile.length() > 0) {
                    val completedState = DownloadState.Completed(outputFile.absolutePath)
                    emit(completedState)
                    stateFlow.value = completedState
                } else {
                    val error = Exception("Downloaded file is empty or doesn't exist")
                    emit(DownloadState.Failed(error))
                    stateFlow.value = DownloadState.Failed(error)
                }

            } catch (e: Exception) {
                if (outputFile.exists()) outputFile.delete()
                val failedState = DownloadState.Failed(e)
                emit(failedState)
                stateFlow.value = failedState
            }

        } catch (e: Exception) {
            val failedState = DownloadState.Failed(e)
            emit(failedState)
            stateFlow.value = failedState
        } finally {
            downloadTasks.remove(trackId)
        }
    }

    override suspend fun pauseDownload(downloadId: String): Result<Unit> {
        val stateFlow = downloadStates[downloadId] ?: return Result.failure(
            IllegalStateException("Download not found: $downloadId")
        )

        downloadTasks[downloadId] = false
        stateFlow.value = DownloadState.Paused
        return Result.success(Unit)
    }

    override suspend fun resumeDownload(downloadId: String): Result<Unit> {
        val metadata = downloadMetadata[downloadId] ?: return Result.failure(
            IllegalStateException("Download metadata not found for resume: $downloadId")
        )

        val stateFlow = downloadStates[downloadId] ?: return Result.failure(
            IllegalStateException("Download state not found for resume: $downloadId")
        )

        downloadTasks[downloadId] = true

        try {
            val outputFile = File(metadata.outputDir, metadata.filename ?: "${metadata.trackId}.mp3")
            val existingBytes = if (outputFile.exists()) outputFile.length() else 0L

            if (metadata.totalBytes > 0 && existingBytes >= metadata.totalBytes) {
                stateFlow.value = DownloadState.Completed(outputFile.absolutePath)
                return Result.success(Unit)
            }

            val response: HttpResponse = httpClient.get(metadata.url) {
                headers {
                    if (existingBytes > 0) {
                        append("Range", "bytes=$existingBytes-")
                    }
                }
            }

            if (!response.status.isSuccess() && response.status.value != 206) { // 206 = Partial Content
                val error = Exception("Resume failed with HTTP ${response.status.value}")
                stateFlow.value = DownloadState.Failed(error)
                return Result.failure(error)
            }

            val responseContentLength = response.headers["Content-Length"]?.toLongOrNull() ?: -1L
            val totalBytes = if (response.status.value == 206) {
                existingBytes + responseContentLength
            } else {
                responseContentLength
            }

            downloadMetadata[downloadId] = metadata.copy(totalBytes = totalBytes, downloadedBytes = existingBytes)

            val channel = response.bodyAsChannel()
            outputFile.parentFile?.mkdirs()

            stateFlow.value = DownloadState.Downloading(
                progress = if (totalBytes > 0) (existingBytes.toFloat() / totalBytes.toFloat()) else -1f,
                downloadedBytes = existingBytes,
                totalBytes = totalBytes
            )

            FileOutputStream(outputFile, true).use { outputStream ->
                var totalBytesRead = existingBytes
                val buffer = ByteArray(8192)

                while (!channel.isClosedForRead && downloadTasks[downloadId] == true) {
                    val bytesRead = channel.readAvailable(buffer)
                    if (bytesRead <= 0) {
                        if (channel.isClosedForRead) break
                        delay(10)
                        continue
                    }

                    outputStream.write(buffer, 0, bytesRead)
                    totalBytesRead += bytesRead

                    downloadMetadata[downloadId] = downloadMetadata[downloadId]?.copy(
                        downloadedBytes = totalBytesRead
                    ) ?: metadata.copy(downloadedBytes = totalBytesRead)

                    val progress = if (totalBytes > 0) (totalBytesRead.toFloat() / totalBytes.toFloat()) else -1f
                    stateFlow.value = DownloadState.Downloading(progress, totalBytesRead, totalBytes)
                }
            }

            if (downloadTasks[downloadId] == true) {
                stateFlow.value = DownloadState.Completed(outputFile.absolutePath)
            } else {
                stateFlow.value = DownloadState.Paused
            }

            return Result.success(Unit)

        } catch (e: Exception) {
            val failedState = DownloadState.Failed(e)
            stateFlow.value = failedState
            return Result.failure(e)
        }
    }

    override suspend fun cancelDownload(downloadId: String): Result<Unit> {
        downloadTasks[downloadId] = false
        downloadStates[downloadId]?.value = DownloadState.Cancelled

        downloadMetadata[downloadId]?.let { metadata ->
            val outputFile = File(metadata.outputDir, metadata.filename ?: "${metadata.trackId}.mp3")
            if (outputFile.exists()) {
                outputFile.delete()
            }
        }

        downloadStates.remove(downloadId)
        downloadMetadata.remove(downloadId)

        return Result.success(Unit)
    }

    override fun getDownloadState(downloadId: String): Flow<DownloadState> {
        return downloadStates[downloadId]?.asStateFlow() ?: flow {
            emit(DownloadState.Failed(Exception("Download not found")))
        }
    }

    override fun getAllDownloads(): Flow<List<com.rmusic.download.models.DownloadItem>> {
        return flow { emit(emptyList()) }
    }
}
