package com.rmusic.android.workers

import android.content.Context
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import com.rmusic.android.Database
import com.rmusic.android.R
import com.rmusic.android.models.DownloadedSong
import com.rmusic.download.DownloadManager
import com.rmusic.download.DownloadState
import com.rmusic.download.HttpDownloadProvider
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import kotlinx.coroutines.flow.first
import java.io.File
import java.util.concurrent.TimeUnit

class DownloadWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val KEY_TRACK_ID = "track_id"
        private const val KEY_TITLE = "title"
        private const val KEY_ARTIST = "artist"
        private const val KEY_DOWNLOAD_URL = "download_url"
        private const val KEY_FILE_PATH = "file_path"
        
        const val TAG = "DownloadWorker"
        
        fun enqueueDownload(
            context: Context,
            trackId: String,
            title: String,
            artist: String?,
            downloadUrl: String,
            filePath: String,
            requiresWifi: Boolean = false
        ) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(
                    if (requiresWifi) NetworkType.UNMETERED else NetworkType.CONNECTED
                )
                .setRequiresBatteryNotLow(true)
                .build()
            
            val inputData = workDataOf(
                KEY_TRACK_ID to trackId,
                KEY_TITLE to title,
                KEY_ARTIST to artist,
                KEY_DOWNLOAD_URL to downloadUrl,
                KEY_FILE_PATH to filePath
            )
            
            val downloadRequest = OneTimeWorkRequestBuilder<DownloadWorker>()
                .setConstraints(constraints)
                .setInputData(inputData)
                .setBackoffCriteria(
                    androidx.work.BackoffPolicy.EXPONENTIAL,
                    30,
                    TimeUnit.SECONDS
                )
                .addTag(TAG)
                .addTag("download_$trackId")
                .build()
            
            WorkManager.getInstance(context).enqueue(downloadRequest)
        }
    }

    private val httpClient = HttpClient(OkHttp) {
        expectSuccess = false
        install(io.ktor.client.plugins.HttpTimeout) {
            requestTimeoutMillis = 300000 // 5 minutes for downloads
            connectTimeoutMillis = 30000
            socketTimeoutMillis = 300000
        }
        install(io.ktor.client.plugins.UserAgent) {
            agent = "RMusic/1.0"
        }
    }

    override suspend fun doWork(): Result {
        val trackId = inputData.getString(KEY_TRACK_ID) ?: return Result.failure()
        val title = inputData.getString(KEY_TITLE) ?: return Result.failure()
        val artist = inputData.getString(KEY_ARTIST)
        val downloadUrl = inputData.getString(KEY_DOWNLOAD_URL) ?: return Result.failure()
        val filePath = inputData.getString(KEY_FILE_PATH) ?: return Result.failure()
        
        return try {
            val outputFile = File(filePath)
            outputFile.parentFile?.mkdirs()

            val downloadProvider = HttpDownloadProvider(httpClient)
            val flow = downloadProvider.downloadTrack(
                trackId = trackId,
                outputDir = outputFile.parentFile!!.absolutePath,
                filename = outputFile.name,
                url = downloadUrl
            )
            flow.collect { state ->
                when (state) {
                    is DownloadState.Completed -> {
                        val downloadedSong = DownloadedSong(
                            id = trackId,
                            title = title,
                            artistsText = artist,
                            albumTitle = null,
                            durationText = null,
                            thumbnailUrl = null,
                            filePath = filePath,
                            fileSize = File(filePath).length(),
                            downloadedAt = System.currentTimeMillis()
                        )
                        Database.insert(downloadedSong)
                        return@collect
                    }
                    is DownloadState.Failed -> {
                        android.util.Log.e(TAG, "Download failed: ${state.error}")
                        throw state.error
                    }
                    else -> { /* Continue */ }
                }
            }
            return Result.success()
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Download worker failed", e)
            
            // Clean up partial file
            try {
                File(filePath).delete()
            } catch (cleanupError: Exception) {
                android.util.Log.w(TAG, "Failed to clean up partial file", cleanupError)
            }
            
            return if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }
    
    override suspend fun getForegroundInfo(): androidx.work.ForegroundInfo {
        val notification = android.app.Notification.Builder(applicationContext, "download_channel")
            .setContentTitle(applicationContext.getString(R.string.downloading_music))
            .setContentText(applicationContext.getString(R.string.download_in_progress))
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setOngoing(true)
            .build()
        
        return androidx.work.ForegroundInfo(1001, notification)
    }
}
