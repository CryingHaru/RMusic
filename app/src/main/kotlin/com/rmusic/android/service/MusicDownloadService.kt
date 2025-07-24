package com.rmusic.android.service
import androidx.media3.common.MediaItem

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
import com.rmusic.android.models.DownloadedAlbum
import com.rmusic.android.models.DownloadedArtist
import com.rmusic.android.Database
import com.rmusic.android.utils.intent
import com.rmusic.android.MainActivity
import com.rmusic.android.utils.InvincibleService
import com.rmusic.android.utils.thumbnail
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.models.bodies.PlayerBody
import com.rmusic.providers.innertube.requests.artistPage
import com.rmusic.providers.innertube.requests.player
import com.rmusic.providers.innertube.models.bodies.BrowseBody
import com.rmusic.android.service.ServiceNotifications
import com.rmusic.android.workers.DownloadWorker
import com.rmusic.download.DownloadManager
import com.rmusic.download.DownloadState
import com.rmusic.download.HttpDownloadProvider
import com.rmusic.download.KDownloadProvider
import com.rmusic.download.models.DownloadItem
import com.rmusic.download.DownloadProvider
import io.ktor.client.HttpClient
import io.ktor.client.request.get
import io.ktor.client.statement.readRawBytes
import io.ktor.http.isSuccess
import io.ktor.client.engine.okhttp.OkHttp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.firstOrNull
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
            @OptIn(kotlinx.coroutines.FlowPreview::class)
            val activeDownloadsFlow = downloadManager.getActiveDownloads()
                .debounce(100)
                .distinctUntilChanged()
            activeDownloadsFlow.collect { activeDownloads ->
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
                    // Get the original song from the database to extract metadata
                    val originalSong = try {
                        Database.song(downloadItem.id).first()
                    } catch (e: Exception) {
                        null
                    }
                    
                    // Get album information if available
                    val albumInfo = originalSong?.let { song ->
                        try {
                            Database.songAlbumInfo(song.id)
                        } catch (e: Exception) {
                            null
                        }
                    }
                    
                    // Get artist information if available
                    val artistsInfo = originalSong?.let { song ->
                        try {
                            val dbArtistsInfo = Database.songArtistInfo(song.id)
                            if (dbArtistsInfo.isNotEmpty()) {
                                android.util.Log.d(TAG, "Found ${dbArtistsInfo.size} artists in database for song ${song.id}")
                                dbArtistsInfo
                            } else {
                                android.util.Log.d(TAG, "No artists found in database for song ${song.id}")
                                emptyList()
                            }
                        } catch (e: Exception) {
                            android.util.Log.w(TAG, "Failed to get artist info from database for song ${song.id}", e)
                            emptyList()
                        }
                    } ?: emptyList()
                    
                    // If we don't have artist info from database, try to create one from downloadItem.artist
                    val fallbackArtistInfo = if (artistsInfo.isEmpty() && !downloadItem.artist.isNullOrBlank()) {
                        android.util.Log.d(TAG, "Creating fallback artist info from downloadItem.artist: ${downloadItem.artist}")
                        val artistName = downloadItem.artist!!
                        listOf(com.rmusic.android.models.Info(
                            id = "fallback_${artistName.hashCode()}",
                            name = artistName
                        ))
                    } else {
                        emptyList()
                    }
                    
                    val finalArtistsInfo = if (artistsInfo.isNotEmpty()) artistsInfo else fallbackArtistInfo
                    
                    val downloadedSong = DownloadedSong(
                        id = "download:${downloadItem.id}",
                        title = downloadItem.title,
                        artistsText = downloadItem.artist ?: originalSong?.artistsText,
                        albumTitle = downloadItem.album ?: albumInfo?.name,
                        albumId = albumInfo?.id,
                        artistIds = finalArtistsInfo.joinToString(",") { it.id }, // Store as comma-separated string
                        durationText = downloadItem.duration?.let { "${it / 1000 / 60}:${String.format("%02d", (it / 1000) % 60)}" } 
                            ?: originalSong?.durationText,
                        thumbnailUrl = downloadItem.thumbnailUrl ?: originalSong?.thumbnailUrl,
                        year = albumInfo?.let { 
                            try {
                                Database.album(it.id).first()?.year
                            } catch (e: Exception) {
                                null
                            }
                        },
                        albumThumbnailUrl = albumInfo?.let { 
                            try {
                                val albumDir = file.parentFile
                                val localCover = File(albumDir, "cover.jpg")
                                if (localCover.exists()) {
                                    "file://${localCover.absolutePath}"
                                } else {
                                    Database.album(it.id).first()?.thumbnailUrl
                                }
                            } catch (e: Exception) {
                                null
                            }
                        },
                        filePath = file.absolutePath,
                        fileSize = file.length()
                    )
                    
                    Database.insert(downloadedSong)
                    
                    // IMMEDIATELY download album cover and artist thumbnail after song download
                    scope.launch {
                        // Download album cover if available - use KDownloader provider instead of HttpClient
                        val albumCoverUrl = downloadItem.thumbnailUrl 
                            ?: originalSong?.thumbnailUrl 
                            ?: albumInfo?.let { 
                                try {
                                    Database.album(it.id).first()?.thumbnailUrl
                                } catch (e: Exception) {
                                    null
                                }
                            }
                        
                        albumCoverUrl?.let { thumbnailUrl ->
                            android.util.Log.d(TAG, "Downloading album cover via KDownloader: $thumbnailUrl")
                            downloadAlbumCoverWithKDownloader(thumbnailUrl, file.parentFile, "cover.jpg")
                        }
                        
                        // Download artist thumbnail - get actual artist profile image
                        finalArtistsInfo.firstOrNull()?.let { artistInfo: com.rmusic.android.models.Info ->
                            try {
                                val artistThumbnailUrl: String? = if (artistInfo.id.startsWith("fallback_")) {
                                    null // No thumbnail for fallback artists
                                } else {
                                    // Try to get artist thumbnail from database first
                                    val dbArtist = Database.artist(artistInfo.id).first()
                                    if (dbArtist?.thumbnailUrl != null) {
                                        dbArtist.thumbnailUrl
                                    } else {
                                        // If not in database, try to fetch from Innertube
                                        android.util.Log.d(TAG, "Fetching artist thumbnail from Innertube for: ${artistInfo.name}")
                                        try {
                                            val artistPageResult = Innertube.artistPage(
                                                BrowseBody(browseId = artistInfo.id)
                                            )?.getOrNull()
                                            val thumbnailUrl = artistPageResult?.thumbnail?.url
                                            if (thumbnailUrl != null) {
                                                android.util.Log.d(TAG, "Found artist thumbnail URL: $thumbnailUrl")
                                            }
                                            thumbnailUrl
                                        } catch (e: Exception) {
                                            android.util.Log.w(TAG, "Failed to fetch artist thumbnail from Innertube", e)
                                            null
                                        }
                                    }
                                }
                                
                                artistThumbnailUrl?.let { thumbnailUrl: String ->
                                    android.util.Log.d(TAG, "Downloading artist thumbnail via KDownloader: $thumbnailUrl")
                                    downloadArtistThumbnailWithKDownloader(thumbnailUrl, file.parentFile?.parentFile, "artist.jpg")
                                }
                            } catch (e: Exception) {
                                android.util.Log.w(TAG, "Error processing artist thumbnail", e)
                            }
                        }
                    }
                    
                    albumInfo?.let { info ->
                        try {
                            val albumData = Database.album(info.id).first()
                            albumData?.let { album ->
                                val downloadedAlbum = DownloadedAlbum(
                                    id = album.id,
                                    title = album.title ?: info.name ?: "Unknown Album",
                                    description = album.description,
                                    thumbnailUrl = File(file.parentFile, "cover.jpg").let { localCover ->
                                        if (localCover.exists()) "file://${localCover.absolutePath}" 
                                        else downloadItem.thumbnailUrl ?: album.thumbnailUrl
                                    },
                                    year = album.year,
                                    authorsText = album.authorsText,
                                    shareUrl = album.shareUrl,
                                    otherInfo = album.otherInfo,
                                    songCount = 1 // We'll update this with actual count later
                                )
                                Database.insert(downloadedAlbum)
                            }
                        } catch (e: Exception) {
                            android.util.Log.e(TAG, "Failed to process album info", e)
                        }
                    }
                    
                    finalArtistsInfo.forEach { artistInfo ->
                        try {
                            // Check if artist already exists in downloads
                            val existingArtist = try {
                                Database.downloadedArtist(artistInfo.id).first()
                            } catch (e: Exception) {
                                null
                            }
                            
                            if (existingArtist != null) {
                                // Update song count for existing artist
                                val updatedArtist = existingArtist.copy(
                                    songCount = existingArtist.songCount + 1,
                                    downloadedAt = System.currentTimeMillis() // Update download timestamp
                                )
                                android.util.Log.d(TAG, "Updating existing DownloadedArtist: id=${artistInfo.id}, songCount=${updatedArtist.songCount}")
                                Database.update(updatedArtist)
                            } else {
                                // Create new DownloadedArtist entry
                                val finalThumbnailUrl = if (artistInfo.id.startsWith("fallback_")) {
                                    null // Don't use album thumbnail for fallback artists
                                } else {
                                    // Try to get actual artist thumbnail from database
                                    try {
                                        Database.artist(artistInfo.id).first()?.thumbnailUrl
                                    } catch (e: Exception) {
                                        null
                                    }
                                }
                                
                                val downloadedArtist = DownloadedArtist(
                                    id = artistInfo.id,
                                    name = artistInfo.name ?: "Unknown Artist",
                                    thumbnailUrl = File(file.parentFile?.parentFile, "artist.jpg").let { localThumbnail ->
                                        if (localThumbnail.exists()) "file://${localThumbnail.absolutePath}"
                                        else finalThumbnailUrl
                                    },
                                    downloadedAt = System.currentTimeMillis(),
                                    bookmarkedAt = null,
                                    songCount = 1
                                )
                                
                                android.util.Log.d(TAG, "Inserting new DownloadedArtist: id=${artistInfo.id}, name=${artistInfo.name}")
                                Database.insert(downloadedArtist)
                            }
                            
                        } catch (e: Exception) {
                            android.util.Log.e(TAG, "Failed to process artist info for ${artistInfo.id}: ${artistInfo.name}", e)
                        }
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in saveCompletedDownload for ${downloadItem.title}", e)
                e.printStackTrace()
            }
        }
    }
    
    private suspend fun downloadAlbumCoverWithKDownloader(thumbnailUrl: String, albumDir: File?, filename: String) {
        if (albumDir == null) {
            android.util.Log.w(TAG, "Album directory is null, cannot download cover")
            return
        }
        
        try {
            // Ensure directory exists
            if (!albumDir.exists()) {
                albumDir.mkdirs()
                android.util.Log.d(TAG, "Created album directory: ${albumDir.absolutePath}")
            }
            
            val coverFile = File(albumDir, filename)
            if (coverFile.exists()) {
                android.util.Log.d(TAG, "Album cover already exists: ${coverFile.absolutePath}")
                return
            }
            
            // Apply high-resolution transformation before downloading
            val highResUrl = thumbnailUrl.thumbnail(1280) ?: thumbnailUrl
            
            android.util.Log.d(TAG, "Downloading album cover via KDownloader from: $highResUrl to: ${coverFile.absolutePath}")
            
            // Use KDownloader provider for thumbnail downloads
            val kdownloadProvider = KDownloadProvider(this@MusicDownloadService)
            
            try {
                kdownloadProvider.downloadTrack(
                    trackId = "cover_${System.currentTimeMillis()}",
                    outputDir = albumDir.absolutePath,
                    filename = filename,
                    url = highResUrl
                ).collect { state ->
                    when (state) {
                        is DownloadState.Completed -> {
                            android.util.Log.d(TAG, "Album cover downloaded successfully via KDownloader: ${state.filePath}")
                        }
                        is DownloadState.Failed -> {
                            throw Exception("KDownloader failed: ${state.error}")
                        }
                        else -> {
                            // Download in progress
                        }
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "KDownloader failed for album cover, fallback to HttpClient", e)
                // Fallback to HttpClient if KDownloader fails - also use high res URL
                val response = httpClient.get(highResUrl)
                if (response.status.isSuccess()) {
                    val bytes = response.readRawBytes()
                    coverFile.writeBytes(bytes)
                    android.util.Log.d(TAG, "Album cover saved via HttpClient fallback: ${coverFile.absolutePath} (${bytes.size} bytes)")
                } else {
                    android.util.Log.e(TAG, "Failed to download album cover, HTTP status: ${response.status}")
                }
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to download album cover", e)
        }
    }
    
    private suspend fun downloadArtistThumbnailWithKDownloader(thumbnailUrl: String, artistDir: File?, filename: String) {
        if (artistDir == null) {
            android.util.Log.w(TAG, "Artist directory is null, cannot download thumbnail")
            return
        }
        
        try {
            // Ensure directory exists
            if (!artistDir.exists()) {
                artistDir.mkdirs()
                android.util.Log.d(TAG, "Created artist directory: ${artistDir.absolutePath}")
            }
            
            val thumbnailFile = File(artistDir, filename)
            if (thumbnailFile.exists()) {
                android.util.Log.d(TAG, "Artist thumbnail already exists: ${thumbnailFile.absolutePath}")
                return
            }
            
            // Apply high-resolution transformation before downloading
            val highResUrl = thumbnailUrl.thumbnail(1280) ?: thumbnailUrl
            
            android.util.Log.d(TAG, "Downloading artist thumbnail via KDownloader from: $highResUrl to: ${thumbnailFile.absolutePath}")
            
            // Use KDownloader provider for thumbnail downloads
            val kdownloadProvider = KDownloadProvider(this@MusicDownloadService)
            
            try {
                kdownloadProvider.downloadTrack(
                    trackId = "artist_${System.currentTimeMillis()}",
                    outputDir = artistDir.absolutePath,
                    filename = filename,
                    url = highResUrl
                ).collect { state ->
                    when (state) {
                        is DownloadState.Completed -> {
                            android.util.Log.d(TAG, "Artist thumbnail downloaded successfully via KDownloader: ${state.filePath}")
                        }
                        is DownloadState.Failed -> {
                            throw Exception("KDownloader failed: ${state.error}")
                        }
                        else -> {
                            // Download in progress
                        }
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e(TAG, "KDownloader failed for artist thumbnail, fallback to HttpClient", e)
                // Fallback to HttpClient if KDownloader fails - also use high res URL
                val response = httpClient.get(highResUrl)
                if (response.status.isSuccess()) {
                    val bytes = response.readRawBytes()
                    thumbnailFile.writeBytes(bytes)
                    android.util.Log.d(TAG, "Artist thumbnail saved via HttpClient fallback: ${thumbnailFile.absolutePath} (${bytes.size} bytes)")
                } else {
                    android.util.Log.e(TAG, "Failed to download artist thumbnail, HTTP status: ${response.status}")
                }
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to download artist thumbnail", e)
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
                    .setContentTitle(getString(R.string.downloading_title, currentDownload.title))
                    .setContentText("${currentDownload.artist ?: getString(R.string.unknown_artist)} • $progress%")
                    .setProgress(100, progress, false)
                
                if (activeDownloads.size > 1) {
                    notificationBuilder.setSubText(getString(R.string.downloads_active, activeDownloads.size))
                }
            }
            is DownloadState.Queued -> {
                notificationBuilder
                    .setContentTitle(getString(R.string.queued_title, currentDownload.title))
                    .setContentText(currentDownload.artist ?: getString(R.string.unknown_artist))
                    .setProgress(100, 0, true)
            }
            is DownloadState.Paused -> {
                notificationBuilder
                    .setContentTitle(getString(R.string.paused_title, currentDownload.title))
                    .setContentText(currentDownload.artist ?: getString(R.string.unknown_artist))
                    .setProgress(100, 0, false)
            }
            else -> {
                notificationBuilder
                    .setContentTitle(getString(R.string.downloading_music))
                    .setContentText(getString(R.string.downloads_in_progress_count, activeDownloads.size))
                    .setProgress(100, 0, true)
            }
        }
        
        return notificationBuilder.build()
    }
    
    private fun createDefaultNotification(): Notification {
        return NotificationCompat.Builder(this, ServiceNotifications.download.id)
            .setSmallIcon(R.drawable.download)
            .setContentTitle(getString(R.string.download_service))
            .setContentText(getString(R.string.preparing_downloads))
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
            "download_playlist" -> {
                android.util.Log.d(TAG, "Download playlist action received")
                
                // Check storage permissions before starting download
                if (!com.rmusic.android.utils.PermissionManager.hasStoragePermissions(this)) {
                    android.util.Log.w(TAG, "Storage permissions not granted, cannot start playlist download")
                    return
                }
                
                handlePlaylistDownload(intent)
            }
            "download_album" -> {
                android.util.Log.d(TAG, "Download album action received")
                
                // Check storage permissions before starting download
                if (!com.rmusic.android.utils.PermissionManager.hasStoragePermissions(this)) {
                    android.util.Log.w(TAG, "Storage permissions not granted, cannot start album download")
                    return
                }
                
                handleAlbumDownload(intent)
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
    
    private fun handlePlaylistDownload(intent: Intent) {
        val playlistId = intent.getStringExtra("playlistId") ?: return
        val playlistName = intent.getStringExtra("playlistName") ?: return
        val songCount = intent.getIntExtra("songCount", 0)
        
        val trackIds = intent.getStringArrayExtra("trackIds") ?: return
        val titles = intent.getStringArrayExtra("titles") ?: return
        val artists = intent.getStringArrayExtra("artists")
        val albums = intent.getStringArrayExtra("albums")
        val thumbnailUrls = intent.getStringArrayExtra("thumbnailUrls")
        val durations = intent.getLongArrayExtra("durations")
        
        android.util.Log.d(TAG, "Starting playlist download: $playlistName with $songCount songs")
        
        scope.launch {
            try {
                // Process each song in the playlist
                for (i in trackIds.indices) {
                    val trackId = trackIds[i]
                    val title = titles[i]
                    val artist = artists?.get(i)
                    val album = albums?.get(i)
                    val thumbnailUrl = thumbnailUrls?.get(i)
                    val duration = durations?.get(i)?.takeIf { it > 0 }
                    
                    // Generate download URL - this would need to be obtained from the provider
                    // For now, we'll skip songs without URLs, but in practice you'd fetch them
                    try {
                        // Try to get the song from database to find streaming URL
                        val song = Database.song(trackId).firstOrNull()
                        if (song != null) {
                            // Generate streaming URL using providers
                            val url = generateStreamingUrl(song)
                            if (url != null) {
                                downloadManager.downloadTrack(
                                    providerId = "kdownloader",
                                    trackId = trackId,
                                    title = title,
                                    artist = artist,
                                    album = album ?: playlistName, // Use playlist name as album if not specified
                                    thumbnailUrl = thumbnailUrl,
                                    duration = duration,
                                    url = url
                                )
                                android.util.Log.d(TAG, "Started download for playlist song: $title")
                                
                                // Add small delay between downloads to avoid overwhelming the system
                                kotlinx.coroutines.delay(500)
                            } else {
                                android.util.Log.w(TAG, "Could not generate URL for song: $title")
                            }
                        } else {
                            android.util.Log.w(TAG, "Song not found in database: $trackId")
                        }
                    } catch (e: Exception) {
                        android.util.Log.e(TAG, "Error downloading playlist song $title", e)
                    }
                }
                
                android.util.Log.d(TAG, "Playlist download initiated for all available songs")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in handlePlaylistDownload", e)
            }
        }
    }
    
    private fun handleAlbumDownload(intent: Intent) {
        val albumId = intent.getStringExtra("albumId") ?: return
        val albumName = intent.getStringExtra("albumName") ?: return
        val songCount = intent.getIntExtra("songCount", 0)

        val trackIds = intent.getStringArrayExtra("trackIds") ?: return
        val titles = intent.getStringArrayExtra("titles") ?: return
        val artists = intent.getStringArrayExtra("artists")
        val albums = intent.getStringArrayExtra("albums")
        val thumbnailUrls = intent.getStringArrayExtra("thumbnailUrls")
        val durations = intent.getLongArrayExtra("durations")

        android.util.Log.d(TAG, "Starting album download: $albumName with $songCount songs")

        scope.launch {
            try {
                // Process each song in the album
                for (i in trackIds.indices) {
                    val trackId = trackIds[i]
                    val title = titles[i]
                    val artist = artists?.get(i)
                    val album = albums?.get(i) ?: albumName
                    val thumbnailUrl = thumbnailUrls?.get(i)
                    val duration = durations?.get(i)?.takeIf { it > 0 }

                    try {
                        // Try to get the song from database to find streaming URL
                        val song = Database.song(trackId).firstOrNull()
                        if (song != null) {
                            // Generate streaming URL using providers
                            val url = generateStreamingUrl(song)
                            if (url != null) {
                                downloadManager.downloadTrack(
                                    providerId = "kdownloader",
                                    trackId = trackId,
                                    title = title,
                                    artist = artist,
                                    album = album,
                                    thumbnailUrl = thumbnailUrl,
                                    duration = duration,
                                    url = url
                                )
                                android.util.Log.d(TAG, "Started download for album song: $title")

                                // Add small delay between downloads to avoid overwhelming the system
                                kotlinx.coroutines.delay(500)
                            } else {
                                android.util.Log.w(TAG, "Could not generate URL for song: $title")
                            }
                        } else {
                            android.util.Log.w(TAG, "Song not found in database: $trackId")
                        }
                    } catch (e: Exception) {
                        android.util.Log.e(TAG, "Error downloading album song $title", e)
                    }
                }

                android.util.Log.d(TAG, "Album download initiated for all available songs")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Error in handleAlbumDownload", e)
            }
        }
    }
    
    private suspend fun generateStreamingUrl(song: com.rmusic.android.models.Song): String? {
        return try {
            // Try to get the streaming URL from the format in database
            val format = Database.format(song.id).firstOrNull()
            if (format != null && !format.url.isNullOrBlank()) {
                return format.url
            }

            // If not in database, fetch from Innertube
            Innertube.player(PlayerBody(videoId = song.id))?.getOrNull()?.let { playerResponse ->
                val bestFormat = playerResponse.streamingData?.adaptiveFormats
                    ?.filter { it.mimeType.contains("audio/mp4") && it.bitrate != null && it.url != null }
                    ?.maxByOrNull { it.bitrate!! }

                bestFormat?.url?.let { url ->
                    // Save the fetched format to the database for future use
                    Database.insert(
                        com.rmusic.android.models.Format(
                            songId = song.id,
                            url = url,
                            bitrate = bestFormat.bitrate,
                            contentLength = bestFormat.contentLength
                        )
                    )
                    return url
                }
            }
            null
        } catch (e: Exception) {
            android.util.Log.w(TAG, "Could not get streaming URL for song ${song.id}", e)
            null
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
        
        // Single track download
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

        // Download entire playlist
        fun downloadPlaylist(
            context: Context,
            playlistId: String,
            playlistName: String,
            songs: List<MediaItem>
        ) {
            android.util.Log.d(TAG, "Starting playlist download: $playlistName with ${songs.size} songs")
            
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "download_playlist")
                putExtra("playlistId", playlistId)
                putExtra("playlistName", playlistName)
                putExtra("songCount", songs.size)
                // Store songs as arrays for the intent
                putExtra("trackIds", songs.map { it.mediaId }.toTypedArray())
                putExtra("titles", songs.map { it.mediaMetadata.title?.toString() ?: "Unknown" }.toTypedArray())
                putExtra("artists", songs.map { it.mediaMetadata.artist?.toString() }.toTypedArray())
                putExtra("albums", songs.map { it.mediaMetadata.albumTitle?.toString() }.toTypedArray())
                putExtra("thumbnailUrls", songs.map { it.mediaMetadata.artworkUri?.toString() }.toTypedArray())
                putExtra("durations", songs.map { it.mediaMetadata.durationMs ?: 0L }.toLongArray())
            }
            
            try {
                context.startService(intent)
                android.util.Log.d(TAG, "Playlist download service started successfully")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Failed to start playlist download service", e)
            }
        }

        // Download entire album
        fun downloadAlbum(
            context: Context,
            albumId: String,
            albumName: String,
            songs: List<MediaItem>
        ) {
            android.util.Log.d(TAG, "Starting album download: $albumName with ${songs.size} songs")
            
            val intent = Intent(context, MusicDownloadService::class.java).apply {
                putExtra("action", "download_album")
                putExtra("albumId", albumId)
                putExtra("albumName", albumName)
                putExtra("songCount", songs.size)
                // Store songs as arrays for the intent
                putExtra("trackIds", songs.map { it.mediaId }.toTypedArray())
                putExtra("titles", songs.map { it.mediaMetadata.title?.toString() ?: "Unknown" }.toTypedArray())
                putExtra("artists", songs.map { it.mediaMetadata.artist?.toString() }.toTypedArray())
                putExtra("albums", songs.map { it.mediaMetadata.albumTitle?.toString() }.toTypedArray())
                putExtra("thumbnailUrls", songs.map { it.mediaMetadata.artworkUri?.toString() }.toTypedArray())
                putExtra("durations", songs.map { it.mediaMetadata.durationMs ?: 0L }.toLongArray())
            }
            
            try {
                context.startService(intent)
                android.util.Log.d(TAG, "Album download service started successfully")
            } catch (e: Exception) {
                android.util.Log.e(TAG, "Failed to start album download service", e)
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
