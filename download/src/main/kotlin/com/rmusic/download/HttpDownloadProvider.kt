package com.rmusic.download

import io.ktor.client.HttpClient
import io.ktor.client.request.get
import io.ktor.client.request.headers
import kotlin.math.pow
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsChannel
import io.ktor.http.isSuccess
import io.ktor.utils.io.ByteReadChannel
import io.ktor.utils.io.readAvailable
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.ConcurrentHashMap

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
    
    /**
     * Downloads a track with the provided URL
     */
    suspend fun downloadTrackWithUrl(
        trackId: String,
        outputDir: String,
        filename: String?,
        url: String
    ): Flow<DownloadState> = flow {
        android.util.Log.d("HttpDownloadProvider", "Starting download for trackId: $trackId")
        android.util.Log.d("HttpDownloadProvider", "URL: $url")
        android.util.Log.d("HttpDownloadProvider", "Output dir: $outputDir")
        android.util.Log.d("HttpDownloadProvider", "Filename: $filename")
        
        val stateFlow = downloadStates.getOrPut(trackId) { 
            MutableStateFlow(DownloadState.Queued) 
        }
        
        downloadTasks[trackId] = true
        
        try {
            android.util.Log.d("HttpDownloadProvider", "Emitting queued state for $trackId")
            emit(DownloadState.Queued)
            stateFlow.value = DownloadState.Queued
            
            val outputFile = File(outputDir, filename ?: "$trackId.mp3")
            android.util.Log.d("HttpDownloadProvider", "Output file: ${outputFile.absolutePath}")
            
            // Store metadata for potential resume
            val metadata = DownloadMetadata(
                trackId = trackId,
                url = url,
                outputDir = outputDir,
                filename = filename
            )
            downloadMetadata[trackId] = metadata
            
            android.util.Log.d("HttpDownloadProvider", "Making HTTP request to $url")
            val response: HttpResponse = httpClient.get(url)
            
            android.util.Log.d("HttpDownloadProvider", "HTTP response status: ${response.status}")
            if (!response.status.isSuccess()) {
                val error = Exception("HTTP ${response.status.value}: ${response.status.description}")
                android.util.Log.e("HttpDownloadProvider", "HTTP request failed for $trackId", error)
                emit(DownloadState.Failed(error))
                stateFlow.value = DownloadState.Failed(error)
                return@flow
            }
            
            val contentLength = response.headers["Content-Length"]?.toLongOrNull() ?: -1L
            android.util.Log.d("HttpDownloadProvider", "Content length: $contentLength bytes")
            val channel = response.bodyAsChannel()
            
            // Update metadata with total bytes
            downloadMetadata[trackId] = metadata.copy(totalBytes = contentLength)
            
            outputFile.parentFile?.mkdirs()
            android.util.Log.d("HttpDownloadProvider", "Created output directory: ${outputFile.parentFile?.absolutePath}")
            
            try {
                // Emit downloading started state
                val startedState = DownloadState.Downloading(
                    progress = 0f,
                    downloadedBytes = 0L,
                    totalBytes = contentLength
                )
                android.util.Log.d("HttpDownloadProvider", "Emitting downloading state for $trackId")
                emit(startedState)
                stateFlow.value = startedState
                
                // Use streaming download with progress tracking
                android.util.Log.d("HttpDownloadProvider", "Starting file write for $trackId")
                outputFile.outputStream().use { outputStream ->
                    var totalBytesRead = 0L
                    val buffer = ByteArray(8192)
                    
                    while (!channel.isClosedForRead && downloadTasks[trackId] == true) {
                        val bytesRead = channel.readAvailable(buffer)
                        if (bytesRead <= 0) {
                            // Check if we're at the end or if there's a temporary lack of data
                            if (channel.isClosedForRead) break
                            kotlinx.coroutines.delay(10) // Brief delay to avoid busy waiting
                            continue
                        }
                        
                        outputStream.write(buffer, 0, bytesRead)
                        outputStream.flush() // Ensure data is written
                        totalBytesRead += bytesRead
                        
                        // Update metadata with current progress
                        downloadMetadata[trackId] = downloadMetadata[trackId]?.copy(
                            downloadedBytes = totalBytesRead
                        ) ?: metadata.copy(downloadedBytes = totalBytesRead)
                        
                        val progress = if (contentLength > 0) {
                            (totalBytesRead.toFloat() / contentLength.toFloat()).coerceIn(0f, 1f)
                        } else {
                            -1f // Indeterminate progress
                        }
                        
                        val downloadingState = DownloadState.Downloading(
                            progress = progress,
                            downloadedBytes = totalBytesRead,
                            totalBytes = contentLength
                        )
                        
                        // Log every 10% progress or every 1MB
                        if (totalBytesRead % (1024 * 1024) == 0L || (contentLength > 0 && totalBytesRead % (contentLength / 10) == 0L)) {
                            android.util.Log.d("HttpDownloadProvider", "Download progress for $trackId: ${(progress * 100).toInt()}% ($totalBytesRead bytes)")
                        }
                        
                        emit(downloadingState)
                        stateFlow.value = downloadingState
                    }
                }
                
                // Check if download was cancelled
                if (downloadTasks[trackId] != true) {
                    android.util.Log.w("HttpDownloadProvider", "Download was cancelled for $trackId")
                    outputFile.delete()
                    val cancelledState = DownloadState.Cancelled
                    emit(cancelledState)
                    stateFlow.value = cancelledState
                    return@flow
                }
                
                android.util.Log.d("HttpDownloadProvider", "Download stream finished for $trackId, file size: ${outputFile.length()} bytes")
                
                // Verify the file was written successfully
                if (outputFile.exists() && outputFile.length() > 0) {
                    // Emit completed state
                    val completedState = DownloadState.Completed(outputFile.absolutePath)
                    android.util.Log.d("HttpDownloadProvider", "Download completed successfully for $trackId: ${outputFile.absolutePath}")
                    emit(completedState)
                    stateFlow.value = completedState
                } else {
                    val error = Exception("Downloaded file is empty or doesn't exist")
                    android.util.Log.e("HttpDownloadProvider", "Download verification failed for $trackId", error)
                    val failedState = DownloadState.Failed(error)
                    emit(failedState)
                    stateFlow.value = failedState
                }
                
            } catch (e: Exception) {
                // Clean up partial file on error
                if (outputFile.exists()) {
                    outputFile.delete()
                }
                val failedState = DownloadState.Failed(e)
                android.util.Log.e("HttpDownloadProvider", "Download failed for $trackId", e)
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
    
    override suspend fun downloadTrack(
        trackId: String,
        outputDir: String,
        filename: String?
    ): Flow<DownloadState> = flow {
        val stateFlow = downloadStates.getOrPut(trackId) { 
            MutableStateFlow(DownloadState.Queued) 
        }
        
        try {
            emit(DownloadState.Queued)
            stateFlow.value = DownloadState.Queued
            
            // This method is deprecated, use downloadTrackWithUrl instead
            val error = Exception("downloadTrack is deprecated, use downloadTrackWithUrl instead")
            emit(DownloadState.Failed(error))
            stateFlow.value = DownloadState.Failed(error)
            
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
        val pausedState = DownloadState.Paused
        stateFlow.value = pausedState
        return Result.success(Unit)
    }
    
    override suspend fun resumeDownload(downloadId: String): Result<Unit> {
        val metadata = downloadMetadata[downloadId] ?: return Result.failure(
            IllegalStateException("Download metadata not found: $downloadId")
        )
        
        val stateFlow = downloadStates[downloadId] ?: return Result.failure(
            IllegalStateException("Download state not found: $downloadId")
        )
        
        downloadTasks[downloadId] = true
        
        try {
            val outputFile = File(metadata.outputDir, metadata.filename ?: "${metadata.trackId}.mp3")
            val existingBytes = if (outputFile.exists()) outputFile.length() else 0L
            
            // If file is already complete, mark as completed
            if (existingBytes > 0 && metadata.totalBytes > 0 && existingBytes >= metadata.totalBytes) {
                val completedState = DownloadState.Completed(outputFile.absolutePath)
                stateFlow.value = completedState
                return Result.success(Unit)
            }
            
            // Resume from where we left off using Range request
            val response: HttpResponse = if (existingBytes > 0) {
                httpClient.get(metadata.url) {
                    headers {
                        append("Range", "bytes=$existingBytes-")
                    }
                }
            } else {
                httpClient.get(metadata.url)
            }
            
            if (!response.status.isSuccess() && response.status.value != 206) { // 206 = Partial Content
                val error = Exception("HTTP ${response.status.value}: ${response.status.description}")
                val failedState = DownloadState.Failed(error)
                stateFlow.value = failedState
                return Result.failure(error)
            }
            
            val contentLength = response.headers["Content-Length"]?.toLongOrNull() ?: -1L
            val totalBytes = if (existingBytes > 0 && contentLength > 0) {
                existingBytes + contentLength
            } else {
                metadata.totalBytes.takeIf { it > 0 } ?: contentLength
            }
            
            // Update metadata with correct total bytes
            downloadMetadata[downloadId] = metadata.copy(
                totalBytes = totalBytes,
                downloadedBytes = existingBytes
            )
            
            val channel = response.bodyAsChannel()
            outputFile.parentFile?.mkdirs()
            
            // Emit downloading state
            val downloadingState = DownloadState.Downloading(
                progress = if (totalBytes > 0) (existingBytes.toFloat() / totalBytes.toFloat()).coerceIn(0f, 1f) else -1f,
                downloadedBytes = existingBytes,
                totalBytes = totalBytes
            )
            stateFlow.value = downloadingState
            
            // Append to existing file or create new one
            FileOutputStream(outputFile, existingBytes > 0).use { outputStream ->
                var totalBytesRead = existingBytes
                val buffer = ByteArray(8192)
                
                while (!channel.isClosedForRead && downloadTasks[downloadId] == true) {
                    val bytesRead = channel.readAvailable(buffer, 0, buffer.size)
                    if (bytesRead == -1) break
                    
                    outputStream.write(buffer, 0, bytesRead)
                    totalBytesRead += bytesRead
                    
                    // Update metadata with current progress
                    downloadMetadata[downloadId] = downloadMetadata[downloadId]?.copy(
                        downloadedBytes = totalBytesRead
                    ) ?: metadata.copy(downloadedBytes = totalBytesRead)
                    
                    val progress = if (totalBytes > 0) {
                        (totalBytesRead.toFloat() / totalBytes.toFloat()).coerceIn(0f, 1f)
                    } else {
                        -1f
                    }
                    
                    val progressState = DownloadState.Downloading(
                        progress = progress,
                        downloadedBytes = totalBytesRead,
                        totalBytes = totalBytes
                    )
                    
                    stateFlow.value = progressState
                }
            }
            
            // Check final state
            if (downloadTasks[downloadId] != true) {
                val pausedState = DownloadState.Paused
                stateFlow.value = pausedState
            } else {
                val completedState = DownloadState.Completed(outputFile.absolutePath)
                stateFlow.value = completedState
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
        val cancelledState = DownloadState.Cancelled
        downloadStates[downloadId]?.value = cancelledState
        
        // Clean up partial file
        downloadMetadata[downloadId]?.let { metadata ->
            val outputFile = File(metadata.outputDir, metadata.filename ?: "${metadata.trackId}.mp3")
            if (outputFile.exists()) {
                outputFile.delete()
            }
        }
        
        // Clean up resources
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
        return flow<List<com.rmusic.download.models.DownloadItem>> { emit(emptyList<com.rmusic.download.models.DownloadItem>()) }
    }
    
    /**
     * Enhanced error handling with retry logic
     */
    private suspend fun handleDownloadError(trackId: String, error: Throwable): DownloadState.Failed {
        android.util.Log.e("HttpDownloadProvider", "Download error for $trackId", error)
        
        // Clean up resources
        downloadTasks.remove(trackId)
        downloadMetadata.remove(trackId)
        
        // Determine if error is retryable
        val isRetryable = when {
            error is java.net.UnknownHostException -> true
            error is java.net.SocketTimeoutException -> true
            error is java.io.IOException && !error.message?.contains("403")!! -> true
            error.message?.contains("Network") == true -> true
            else -> false
        }
        
        return DownloadState.Failed(error, isRetryable = isRetryable)
    }
    
    /**
     * Enhanced download with better error handling and logging
     */
    private suspend fun enhancedDownload(
        trackId: String,
        url: String,
        outputDir: String,
        filename: String?,
        maxRetries: Int = 3
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
            
            while (true) {
                try {
                    response = httpClient.get(url)
                    contentLength = response.headers["Content-Length"]?.toLongOrNull() ?: -1L
                    break
                } catch (e: Exception) {
                    retries++
                    android.util.Log.e("HttpDownloadProvider", "HTTP request failed for $trackId, attempt $retries", e)
                    
                    if (retries >= maxRetries) {
                        val error = Exception("Failed to download $trackId after $retries attempts")
                        emit(DownloadState.Failed(error))
                        stateFlow.value = DownloadState.Failed(error)
                        return@flow
                    }
                    
                    // Exponential backoff
                    val delayTime = (1000L * 2.0.pow(retries)).toLong()
                    android.util.Log.d("HttpDownloadProvider", "Retrying in ${delayTime}ms")
                    kotlinx.coroutines.delay(delayTime)
                }
            }
            
            android.util.Log.d("HttpDownloadProvider", "HTTP response status: ${response.status}")
            if (!response.status.isSuccess()) {
                val error = Exception("HTTP ${response.status.value}: ${response.status.description}")
                android.util.Log.e("HttpDownloadProvider", "HTTP request failed for $trackId", error)
                emit(DownloadState.Failed(error))
                stateFlow.value = DownloadState.Failed(error)
                return@flow
            }
            
            val channel = response.bodyAsChannel()
            
            // Update metadata with total bytes
            downloadMetadata[trackId] = metadata.copy(totalBytes = contentLength)
            
            outputFile.parentFile?.mkdirs()
            android.util.Log.d("HttpDownloadProvider", "Created output directory: ${outputFile.parentFile?.absolutePath}")
            
            try {
                // Emit downloading started state
                val startedState = DownloadState.Downloading(
                    progress = 0f,
                    downloadedBytes = 0L,
                    totalBytes = contentLength
                )
                android.util.Log.d("HttpDownloadProvider", "Emitting downloading state for $trackId")
                emit(startedState)
                stateFlow.value = startedState
                
                // Use streaming download with progress tracking
                android.util.Log.d("HttpDownloadProvider", "Starting file write for $trackId")
                outputFile.outputStream().use { outputStream ->
                    var totalBytesRead = 0L
                    val buffer = ByteArray(8192)
                    
                    while (!channel.isClosedForRead && downloadTasks[trackId] == true) {
                        val bytesRead = channel.readAvailable(buffer)
                        if (bytesRead <= 0) {
                            // Check if we're at the end or if there's a temporary lack of data
                            if (channel.isClosedForRead) break
                            kotlinx.coroutines.delay(10) // Brief delay to avoid busy waiting
                            continue
                        }
                        
                        outputStream.write(buffer, 0, bytesRead)
                        outputStream.flush() // Ensure data is written
                        totalBytesRead += bytesRead
                        
                        // Update metadata with current progress
                        downloadMetadata[trackId] = downloadMetadata[trackId]?.copy(
                            downloadedBytes = totalBytesRead
                        ) ?: metadata.copy(downloadedBytes = totalBytesRead)
                        
                        val progress = if (contentLength > 0) {
                            (totalBytesRead.toFloat() / contentLength.toFloat()).coerceIn(0f, 1f)
                        } else {
                            -1f // Indeterminate progress
                        }
                        
                        val downloadingState = DownloadState.Downloading(
                            progress = progress,
                            downloadedBytes = totalBytesRead,
                            totalBytes = contentLength
                        )
                        
                        // Log every 10% progress or every 1MB
                        if (totalBytesRead % (1024 * 1024) == 0L || (contentLength > 0 && totalBytesRead % (contentLength / 10) == 0L)) {
                            android.util.Log.d("HttpDownloadProvider", "Download progress for $trackId: ${(progress * 100).toInt()}% ($totalBytesRead bytes)")
                        }
                        
                        emit(downloadingState)
                        stateFlow.value = downloadingState
                    }
                }
                
                // Check if download was cancelled
                if (downloadTasks[trackId] != true) {
                    android.util.Log.w("HttpDownloadProvider", "Download was cancelled for $trackId")
                    outputFile.delete()
                    val cancelledState = DownloadState.Cancelled
                    emit(cancelledState)
                    stateFlow.value = cancelledState
                    return@flow
                }
                
                android.util.Log.d("HttpDownloadProvider", "Download stream finished for $trackId, file size: ${outputFile.length()} bytes")
                
                // Verify the file was written successfully
                if (outputFile.exists() && outputFile.length() > 0) {
                    // Emit completed state
                    val completedState = DownloadState.Completed(outputFile.absolutePath)
                    android.util.Log.d("HttpDownloadProvider", "Download completed successfully for $trackId: ${outputFile.absolutePath}")
                    emit(completedState)
                    stateFlow.value = completedState
                } else {
                    val error = Exception("Downloaded file is empty or doesn't exist")
                    android.util.Log.e("HttpDownloadProvider", "Download verification failed for $trackId", error)
                    val failedState = DownloadState.Failed(error)
                    emit(failedState)
                    stateFlow.value = failedState
                }
                
            } catch (e: Exception) {
                // Clean up partial file on error
                if (outputFile.exists()) {
                    outputFile.delete()
                }
                val failedState = DownloadState.Failed(e)
                android.util.Log.e("HttpDownloadProvider", "Download failed for $trackId", e)
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
}
