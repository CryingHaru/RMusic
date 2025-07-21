package com.rmusic.android.service

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import androidx.annotation.OptIn
import androidx.core.app.NotificationCompat
import androidx.core.content.getSystemService
import androidx.media3.common.util.UnstableApi
import androidx.work.WorkManager
import com.rmusic.android.R
import com.rmusic.android.models.DownloadedSong
import com.rmusic.android.Database
import com.rmusic.android.utils.intent
import com.rmusic.android.MainActivity
import com.rmusic.android.utils.InvincibleService
import com.rmusic.android.service.ServiceNotifications
import com.rmusic.android.workers.DownloadWorker
import com.rmusic.download.DownloadManager
import com.rmusic.download.DownloadState
import com.rmusic.download.HttpDownloadProvider
import com.rmusic.download.KDownloadProvider
import com.rmusic.download.models.DownloadItem
import com.rmusic.download.DownloadProvider
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import java.io.File

// Global state for downloads
private val mutableDownloadState = MutableStateFlow(false)
val downloadState = mutableDownloadState.asStateFlow()

private val mutableActiveDownloads = MutableStateFlow<List<DownloadItem>>(emptyList())
val activeDownloads = mutableActiveDownloads.asStateFlow()

@OptIn(UnstableApi::class)
class MusicDownloadService : InvincibleService() {
    
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var downloadManager: DownloadManager
    private lateinit var notificationManager: NotificationManager
    private var currentActiveDownloads: List<DownloadItem> = emptyList()
    
    private val httpClient = HttpClient(OkHttp) {
        expectSuccess = false // Allow handling of non-success responses
        install(io.ktor.client.plugins.HttpTimeout) {
            requestTimeoutMillis = 60000 // 60 seconds
            connectTimeoutMillis = 30000 // 30 seconds
            socketTimeoutMillis = 60000  // 60 seconds
        }
        install(io.ktor.client.plugins.UserAgent) {
            agent = "RMusic/1.0"
        }
    }
    
    // InvincibleService abstract members
    override val isInvincibilityEnabled: Boolean = true  // Enable to keep service alive during downloads
    override val notificationId: Int get() = ServiceNotifications.download.notificationId!!
    
    override fun shouldBeInvincible(): Boolean {
        return if (::downloadManager.isInitialized) {
            try {
                currentActiveDownloads.isNotEmpty()
            } catch (e: Exception) {
                false
            }
        } else {
            false
        }
    }
    
    override fun startForeground() {
        // Start foreground when there are active downloads
        if (::downloadManager.isInitialized) {
            try {
                if (currentActiveDownloads.isNotEmpty()) {
                    val notification = createDownloadNotification(currentActiveDownloads)
                    startForeground(notificationId, notification)
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error starting foreground", e)
            }
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        
        android.util.Log.d(TAG, "MusicDownloadService onCreate called")
        
        notificationManager = getSystemService()!!
        
        // Check storage permissions before initializing
        if (!com.rmusic.android.utils.PermissionManager.hasStoragePermissions(this)) {
            android.util.Log.w(TAG, "Storage permissions not granted, downloads may fail")
        }
        
        // Initialize download manager with external storage Music directory
        val musicDir = File(android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_MUSIC), "RMusic")
        musicDir.mkdirs()
        
        android.util.Log.d(TAG, "Music directory: ${musicDir.absolutePath}")
        
        val providers: Map<String, DownloadProvider> = mapOf(
            "innertube" to HttpDownloadProvider(httpClient),
            "http" to HttpDownloadProvider(httpClient),
            "kdownloader" to KDownloadProvider(this) // Add KDownloadProvider
        )
        
        downloadManager = DownloadManager(musicDir, providers, this)
        
        android.util.Log.d(TAG, "DownloadManager initialized")
        
        // Monitor download state changes
        scope.launch {
            downloadManager.getActiveDownloads()
                .debounce(100)
                .distinctUntilChanged()
                .collect { activeDownloads ->
                    android.util.Log.d(TAG, "Active downloads: ${activeDownloads.size}")
                    currentActiveDownloads = activeDownloads  // Update current state
                    mutableDownloadState.value = activeDownloads.isNotEmpty()
                    mutableActiveDownloads.value = activeDownloads
                    
                    if (activeDownloads.isNotEmpty()) {
                        showDownloadNotification(activeDownloads)
                        // Keep service invincible while downloading
                        if (isInvincibilityEnabled && shouldBeInvincible()) {
                            startForeground()
                        }
                    } else {
                        hideDownloadNotification()
                    }
                }
        }
        
        // Monitor completed downloads to add to database
        scope.launch {
            downloadManager.downloads.collect { downloadsMap ->
                android.util.Log.d(TAG, "Downloads map updated: ${downloadsMap.size} items")
                downloadsMap.values.forEach { downloadItem ->
                    if (downloadItem.state is DownloadState.Completed) {
                        saveCompletedDownload(downloadItem)
                    }
                }
            }
        }
    }
    
    private fun saveCompletedDownload(downloadItem: DownloadItem) {
        scope.launch {
            try {
                val file = File((downloadItem.state as DownloadState.Completed).filePath)
                if (file.exists()) {
                    val downloadedSong = DownloadedSong(
                        id = "download:${downloadItem.id}",
                        title = downloadItem.title,
                        artistsText = downloadItem.artist,
                        albumTitle = downloadItem.album,
                        durationText = downloadItem.duration?.let { "${it / 1000 / 60}:${(it / 1000) % 60}" },
                        thumbnailUrl = downloadItem.thumbnailUrl,
                        filePath = file.absolutePath,
                        fileSize = file.length()
                    )
                    
                    Database.insert(downloadedSong)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
    
    private fun showDownloadNotification(activeDownloads: List<DownloadItem>) {
        if (activeDownloads.isEmpty()) return
        
        val notification = createDownloadNotification(activeDownloads)
        
        // If service is not in foreground, start it
        try {
            startForeground(notificationId, notification)
            android.util.Log.d(TAG, "Download notification shown in foreground")
        } catch (e: Exception) {
            // Fallback to regular notification
            notificationManager.notify(notificationId, notification)
            android.util.Log.d(TAG, "Download notification shown as regular notification")
        }
    }
    
    private fun createDownloadNotification(activeDownloads: List<DownloadItem>): Notification {
        val currentDownload = activeDownloads.firstOrNull() ?: return createDefaultNotification()
        val downloadState = currentDownload.state
        
        val notificationBuilder = NotificationCompat.Builder(this, ServiceNotifications.download.id)
            .setSmallIcon(R.drawable.download)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)  // Changed from LOW to DEFAULT
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setContentIntent(
                PendingIntent.getActivity(
                    this,
                    0,
                    intent<MainActivity>(),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
        
        when (downloadState) {
            is DownloadState.Downloading -> {
                val progress = (downloadState.progress * 100).toInt()
                notificationBuilder
                    .setContentTitle("Downloading: ${currentDownload.title}")
                    .setContentText("${currentDownload.artist ?: "Unknown Artist"} • $progress%")
                    .setProgress(100, progress, false)
                
                if (activeDownloads.size > 1) {
                    notificationBuilder.setSubText("${activeDownloads.size} downloads active")
                }
            }
            is DownloadState.Queued -> {
                notificationBuilder
                    .setContentTitle("Queued: ${currentDownload.title}")
                    .setContentText(currentDownload.artist ?: "Unknown Artist")
                    .setProgress(100, 0, true)
            }
            is DownloadState.Paused -> {
                notificationBuilder
                    .setContentTitle("Paused: ${currentDownload.title}")
                    .setContentText(currentDownload.artist ?: "Unknown Artist")
                    .setProgress(100, 0, false)
            }
            else -> {
                notificationBuilder
                    .setContentTitle("Downloading Music")
                    .setContentText("${activeDownloads.size} downloads in progress")
                    .setProgress(100, 0, true)
            }
        }
        
        return notificationBuilder.build()
    }
    
    private fun createDefaultNotification(): Notification {
        return NotificationCompat.Builder(this, ServiceNotifications.download.id)
            .setSmallIcon(R.drawable.download)
            .setContentTitle("Download Service")
            .setContentText("Preparing downloads...")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
    }
    
    private fun hideDownloadNotification() {
        try {
            stopForeground(Service.STOP_FOREGROUND_REMOVE)
            android.util.Log.d(TAG, "Stopped foreground service and removed notification")
        } catch (e: Exception) {
            notificationManager.cancel(notificationId)
            android.util.Log.d(TAG, "Cancelled download notification")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        httpClient.close()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        android.util.Log.d(TAG, "onStartCommand called with intent: $intent")
        intent?.let { 
            android.util.Log.d(TAG, "Intent extras: ${it.extras}")
            handleIntent(it) 
        }
        return START_STICKY
    }
    
    private fun handleIntent(intent: Intent) {
        android.util.Log.d(TAG, "handleIntent called")
        when (intent.getStringExtra("action")) {
            "download" -> {
                android.util.Log.d(TAG, "Download action received")
                
                // Check storage permissions before starting download
                if (!com.rmusic.android.utils.PermissionManager.hasStoragePermissions(this)) {
                    android.util.Log.w(TAG, "Storage permissions not granted, cannot start download")
                    return
                }
                
                val trackId = intent.getStringExtra("trackId") ?: return
                val title = intent.getStringExtra("title") ?: return
                val artist = intent.getStringExtra("artist")
                val album = intent.getStringExtra("album")
                val thumbnailUrl = intent.getStringExtra("thumbnailUrl")
                val duration = intent.getLongExtra("duration", 0).takeIf { it > 0 }
                val url = intent.getStringExtra("url") ?: return
                
                android.util.Log.d(TAG, "Starting download: $title")
                android.util.Log.d(TAG, "URL: $url")
                
                scope.launch {
                    try {
                        android.util.Log.d(TAG, "About to call downloadManager.downloadTrack for $title")
                        
                        // Try immediate download using KDownloader first, fallback to other providers
                        try {
                            val providerId = when {
                                url.contains("youtube") || url.contains("googlevideo") -> "kdownloader"
                                else -> "kdownloader"
                            }
                            
                            downloadManager.downloadTrack(
                                providerId = providerId,
                                trackId = trackId,
                                title = title,
                                artist = artist,
                                album = album,
                                thumbnailUrl = thumbnailUrl,
                                duration = duration,
                                url = url
                            )
                            
                            android.util.Log.d(TAG, "Download initiated for $title")
                        } catch (downloadError: Exception) {
                            android.util.Log.w(TAG, "Immediate download failed for $title", downloadError)
                            
                            // If immediate download fails, check if we should retry with WorkManager
                            if (handleDownloadError(trackId, downloadError)) {
                                android.util.Log.d(TAG, "Scheduling background download for $title")
                                scheduleBackgroundDownload(trackId, title, artist, url)
                            }
                        }
                        
                    } catch (e: Exception) {
                        android.util.Log.e(TAG, "Error starting download for $title", e)
                    }
                }
            }
            "pause" -> {
                val trackId = intent.getStringExtra("trackId") ?: return
                scope.launch {
                    downloadManager.pauseDownload(trackId)
                }
            }
            "resume" -> {
                val trackId = intent.getStringExtra("trackId") ?: return
                scope.launch {
                    downloadManager.resumeDownload(trackId)
                }
            }
            "cancel" -> {
                val trackId = intent.getStringExtra("trackId") ?: return
                scope.launch {
                    downloadManager.cancelDownload(trackId)
                }
            }
            "cleanup" -> {
                val days = intent.getIntExtra("days", 7)
                scope.launch {
                    try {
                        downloadManager.cleanUpDownloads(days)
                        android.util.Log.d(TAG, "Cleaned up old download files ($days days)")
                    } catch (e: Exception) {
                        android.util.Log.e(TAG, "Error during cleanup", e)
                    }
                }
            }
            else -> {
                android.util.Log.w(TAG, "Unknown action: ${intent.getStringExtra("action")}")
            }
        }
    }
    
    // WorkManager integration for background downloads
    private fun scheduleBackgroundDownload(
        trackId: String,
        title: String,
        artist: String?,
        url: String,
        requiresWifi: Boolean = false
    ) {
        val musicDir = File(getExternalFilesDir(null), "Music")
        val fileName = "${title.replace(Regex("[^A-Za-z0-9\\s-_]"), "")}.mp3"
        val filePath = File(musicDir, fileName).absolutePath
        
        DownloadWorker.enqueueDownload(
            context = this,
            trackId = trackId,
            title = title,
            artist = artist,
            downloadUrl = url,
            filePath = filePath,
            requiresWifi = requiresWifi
        )
    }
    
    // Enhanced error handling with intelligent retries
    private fun handleDownloadError(trackId: String, error: Throwable): Boolean {
        return when {
            error is java.net.UnknownHostException -> {
                // Network connectivity issue - schedule for retry with WorkManager
                android.util.Log.w(TAG, "Network error for $trackId - scheduling WorkManager retry")
                true // Retry with WorkManager
            }
            error is java.net.SocketTimeoutException -> {
                // Timeout - schedule for retry with different conditions
                android.util.Log.w(TAG, "Timeout error for $trackId - scheduling WorkManager retry")
                true // Retry with WorkManager
            }
            error.message?.contains("403") == true || error.message?.contains("401") == true -> {
                // Authorization error - don't retry
                android.util.Log.e(TAG, "Authorization error for $trackId - not retrying")
                false
            }
            error.message?.contains("404") == true -> {
                // Not found - don't retry
                android.util.Log.e(TAG, "Resource not found for $trackId - not retrying")
                false
            }
            else -> {
                // Unknown error - retry once with WorkManager
                android.util.Log.w(TAG, "Unknown error for $trackId - scheduling WorkManager retry", error)
                true
            }
        }
    }
    
    companion object {
        private const val TAG = "MusicDownloadService"
        
        // Cleanup old files
        fun cleanUp(context: Context, days: Int) {
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "cleanup")
                putExtra("days", days)
            }
            context.startService(intent)
        }
        
        // Other existing companion functions...
        fun download(
            context: Context,
            trackId: String,
            title: String,
            artist: String? = null,
            album: String? = null,
            thumbnailUrl: String? = null,
            duration: Long? = null,
            url: String
        ) {
            android.util.Log.d(TAG, "Starting download for: $title by $artist")
            android.util.Log.d(TAG, "URL: $url")
            
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "download")
                putExtra("trackId", trackId)
                putExtra("title", title)
                putExtra("artist", artist)
                putExtra("album", album)
                putExtra("thumbnailUrl", thumbnailUrl)
                putExtra("duration", duration)
                putExtra("url", url)
            }
            
            try {
                context.startService(intent)
                android.util.Log.d(TAG, "Service started successfully")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Failed to start service", e)
            }
        }

        fun pause(context: Context, trackId: String) {
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "pause")
                putExtra("trackId", trackId)
            }
            context.startService(intent)
        }

        fun resume(context: Context, trackId: String) {
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "resume")
                putExtra("trackId", trackId)
            }
            context.startService(intent)
        }

        fun cancel(context: Context, trackId: String) {
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "cancel")
                putExtra("trackId", trackId)
            }
            context.startService(intent)
        }
    }
}
