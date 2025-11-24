package com.rmusic.android.service

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Color
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.MediaDescription
import android.media.MediaMetadata
import android.media.audiofx.BassBoost
import android.media.audiofx.LoudnessEnhancer
import android.media.audiofx.PresetReverb
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Bundle
import android.os.StatFs
import android.os.SystemClock
import android.provider.MediaStore
import android.support.v4.media.session.MediaSessionCompat
import androidx.annotation.OptIn
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.app.NotificationCompat
import androidx.core.content.getSystemService
import androidx.core.net.toUri
import androidx.media3.common.AudioAttributes
import androidx.media3.common.AuxEffectInfo
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.Timeline
import androidx.media3.common.audio.SonicAudioProcessor
import androidx.media3.common.util.Log
import androidx.media3.common.util.UnstableApi
import androidx.media3.database.StandaloneDatabaseProvider
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DataSpec
import androidx.media3.datasource.HttpDataSource.InvalidResponseCodeException
import androidx.media3.datasource.ResolvingDataSource
import androidx.media3.datasource.cache.Cache
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.datasource.cache.NoOpCacheEvictor
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.analytics.AnalyticsListener
import androidx.media3.exoplayer.analytics.PlaybackStats
import androidx.media3.exoplayer.analytics.PlaybackStatsListener
import androidx.media3.exoplayer.audio.AudioSink
import androidx.media3.exoplayer.audio.DefaultAudioOffloadSupportProvider
import androidx.media3.exoplayer.audio.DefaultAudioSink
import androidx.media3.exoplayer.audio.DefaultAudioSink.DefaultAudioProcessorChain
import androidx.media3.exoplayer.audio.SilenceSkippingAudioProcessor
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.upstream.DefaultLoadErrorHandlingPolicy
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy
import androidx.media3.exoplayer.upstream.Loader.UnexpectedLoaderException
import androidx.media3.extractor.DefaultExtractorsFactory
import com.rmusic.android.BuildConfig
import com.rmusic.android.Database
import com.rmusic.android.MainActivity
import com.rmusic.android.R
import com.rmusic.android.models.Event
import com.rmusic.android.models.Format
import com.rmusic.android.models.QueuedMediaItem
import com.rmusic.android.models.Song
import com.rmusic.android.models.SongWithContentLength
import com.rmusic.android.preferences.AppearancePreferences
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.preferences.PlayerPreferences
import com.rmusic.android.query
import com.rmusic.android.service.MusicDownloadService
import com.rmusic.android.transaction
import com.rmusic.android.utils.ActionReceiver
import com.rmusic.android.utils.ConditionalCacheDataSourceFactory
import com.rmusic.android.utils.DeviceConstraints
import com.rmusic.android.utils.GlyphInterface
import com.rmusic.android.utils.InvincibleService
import com.rmusic.android.utils.TimerJob
import com.rmusic.android.utils.activityPendingIntent
import com.rmusic.android.utils.asDataSource
import com.rmusic.android.utils.asMediaItem
import com.rmusic.android.utils.broadcastPendingIntent
import com.rmusic.android.utils.findCause
import com.rmusic.android.utils.findNextMediaItemById
import com.rmusic.android.utils.forcePlayFromBeginning
import com.rmusic.android.utils.forceSeekToNext
import com.rmusic.android.utils.forceSeekToPrevious
import com.rmusic.android.utils.get
import com.rmusic.android.utils.handleRangeErrors
import com.rmusic.android.utils.handleUnknownErrors
import com.rmusic.android.utils.intent
import com.rmusic.android.utils.mediaItems
import com.rmusic.android.utils.progress
import com.rmusic.android.utils.readOnlyWhen
import com.rmusic.android.utils.retryIf
import com.rmusic.android.utils.setPlaybackPitch
import com.rmusic.android.utils.shouldBePlaying
import com.rmusic.android.utils.thumbnail
import com.rmusic.android.utils.timer
import com.rmusic.android.utils.toast
import com.rmusic.android.utils.withFallback
import com.rmusic.android.utils.youtubeDataSource
import com.rmusic.compose.preferences.SharedPreferencesProperty
import com.rmusic.core.data.enums.ExoPlayerDiskCacheSize
import com.rmusic.core.data.utils.UriCache
import com.rmusic.core.ui.utils.EqualizerIntentBundleAccessor
import com.rmusic.core.ui.utils.isAtLeastAndroid10
import com.rmusic.core.ui.utils.isAtLeastAndroid12
import com.rmusic.core.ui.utils.isAtLeastAndroid13
import com.rmusic.core.ui.utils.isAtLeastAndroid6
import com.rmusic.core.ui.utils.isAtLeastAndroid8
import com.rmusic.core.ui.utils.isAtLeastAndroid9
import com.rmusic.core.ui.utils.songBundle
import com.rmusic.core.ui.utils.streamVolumeFlow
import com.rmusic.providers.intermusic.IntermusicProvider
import com.rmusic.providers.sponsorblock.SponsorBlock
import com.rmusic.providers.sponsorblock.models.Action
import com.rmusic.providers.sponsorblock.models.Category
import com.rmusic.providers.sponsorblock.requests.segments
import io.ktor.client.plugins.ClientRequestException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.cancellable
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flatMapMerge
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.takeWhile
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.yield
import kotlinx.datetime.Instant
import java.io.EOFException
import java.io.File
import java.io.IOException
import java.util.LinkedHashMap
import java.util.concurrent.CountDownLatch
import kotlin.math.roundToInt
import kotlin.time.Duration.Companion.milliseconds
import android.os.Binder as AndroidBinder

const val LOCAL_KEY_PREFIX = "local:"
private const val TAG = "PlayerService"
private const val LIKE_ACTION = "LIKE"
private const val LOOP_ACTION = "LOOP"

@get:OptIn(UnstableApi::class)
val DataSpec.isLocal get() = key?.startsWith(LOCAL_KEY_PREFIX) == true
val MediaItem.isLocal get() = mediaId.startsWith(LOCAL_KEY_PREFIX)
val Song.isLocal get() = id.startsWith(LOCAL_KEY_PREFIX)

private fun DataSpec.ensureRangeHeader(): DataSpec {
    val hasRangeHeader = httpRequestHeaders?.keys?.any { it.equals("Range", ignoreCase = true) } == true
    if (hasRangeHeader || position <= 0) return this

    val end = length.takeIf { it != C.LENGTH_UNSET.toLong() }?.let { position + it - 1 }
    val value = buildString {
        append("bytes=")
        append(position)
        append('-')
        if (end != null) append(end)
    }

    val newHeaders = httpRequestHeaders?.let { LinkedHashMap(it).apply { put("Range", value) } }
        ?: mapOf("Range" to value)

    return buildUpon().setHttpRequestHeaders(newHeaders).build()
}

@kotlin.OptIn(ExperimentalCoroutinesApi::class)
@OptIn(UnstableApi::class)
class PlayerService : InvincibleService(), Player.Listener, PlaybackStatsListener.Callback {
    private lateinit var mediaSessionInternal: MediaSession
    private lateinit var cacheInternal: Cache
    private lateinit var playerInternal: ExoPlayer
    private val initLock = Any()

    @Volatile private var isPlayerStackInitialized = false

    private val mediaSession: MediaSession get() { ensurePlayerStackInitialized(); return mediaSessionInternal }
    private val cache: Cache get() { ensurePlayerStackInitialized(); return cacheInternal }
    private val player: ExoPlayer get() { ensurePlayerStackInitialized(); return playerInternal }

    private val temporalCache = TemporalSmartCache()
    private val playbackStateMutex = Mutex()
    private val metadataBuilder = MediaMetadata.Builder()
    private val binder = Binder()
    private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
    private val lastProviderSource = MutableStateFlow("Intermusic")
    private val intermusicProvider by lazy { IntermusicProvider.shared() }
    private val notificationActionReceiver = NotificationActionReceiver()
    private val autoDownloadedSongs = mutableSetOf<String>()
    private val retryAttempts = mutableMapOf<String, Int>()
    private val glyphInterface by lazy { GlyphInterface(applicationContext) }
    
    private var timerJob: TimerJob? by mutableStateOf(null)
    private var preferenceUpdaterJob: Job? = null
    private var volumeNormalizationJob: Job? = null
    private var sponsorBlockJob: Job? = null
    private var currentRetryJob: Job? = null
    private var audioManager: AudioManager? = null
    private var audioDeviceCallback: AudioDeviceCallback? = null
    private var loudnessEnhancer: LoudnessEnhancer? = null
    private var bassBoost: BassBoost? = null
    private var reverb: PresetReverb? = null
    private var isNotificationStarted = false
    private var poiTimestamp: Long? by mutableStateOf(null)
    
    private lateinit var bitmapProvider: BitmapProvider

    override var isInvincibilityEnabled by mutableStateOf(false)
    override val notificationId get() = ServiceNotifications.default.notificationId!!

    private val maxRetries = 2
    private val retryDelayMs = 1000L

    private val mediaItemState = MutableStateFlow<MediaItem?>(null)
    private val isLikedState = mediaItemState
        .flatMapMerge { item ->
            item?.mediaId?.let { Database.likedAt(it).distinctUntilChanged().cancellable() } ?: flowOf(null)
        }
        .map { it != null }
        .onEach { updateNotification() }
        .stateIn(scope = coroutineScope, started = SharingStarted.Eagerly, initialValue = false)

    private val defaultActions = PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_PLAY_PAUSE or PlaybackState.ACTION_STOP or
            PlaybackState.ACTION_SKIP_TO_PREVIOUS or PlaybackState.ACTION_SKIP_TO_NEXT or
            PlaybackState.ACTION_SKIP_TO_QUEUE_ITEM or PlaybackState.ACTION_SEEK_TO or
            PlaybackState.ACTION_REWIND or PlaybackState.ACTION_PLAY_FROM_SEARCH

    private val stateBuilder get() = PlaybackState.Builder()
        .setActions(if (isAtLeastAndroid12) defaultActions or PlaybackState.ACTION_SET_PLAYBACK_SPEED else defaultActions)
        .addCustomAction(
            PlaybackState.CustomAction.Builder(
                LIKE_ACTION, getString(R.string.like),
                if (isLikedState.value) R.drawable.heart else R.drawable.heart_outline
            ).build()
        )
        .addCustomAction(
            PlaybackState.CustomAction.Builder(
                LOOP_ACTION, getString(R.string.queue_loop),
                if (PlayerPreferences.trackLoopEnabled) R.drawable.repeat_on else R.drawable.repeat
            ).build()
        )

    override fun onBind(intent: Intent?): AndroidBinder {
        super.onBind(intent)
        return binder
    }

    override fun onCreate() {
        super.onCreate()
        glyphInterface.tryInit()
        notificationActionReceiver.register()
        bitmapProvider = BitmapProvider(
            getBitmapSize = { (512 * resources.displayMetrics.density).roundToInt().coerceAtMost(AppearancePreferences.maxThumbnailSize) },
            getColor = { if (it) Color.BLACK else Color.WHITE }
        )
        isInvincibilityEnabled = PlayerPreferences.isInvincibilityEnabled
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        runCatching {
            if (isPlayerStackInitialized) {
                maybeSavePlayerQueue()
                currentRetryJob?.cancel()
                retryAttempts.clear()
                temporalCache.clearAll(cacheInternal)
                playerInternal.removeListener(this)
                playerInternal.stop()
                playerInternal.release()
                mediaSessionInternal.isActive = false
                mediaSessionInternal.release()
                cacheInternal.release()
            }
            unregisterReceiver(notificationActionReceiver)
            audioManager?.unregisterAudioDeviceCallback(audioDeviceCallback)
            audioDeviceCallback = null
            loudnessEnhancer?.release()
            preferenceUpdaterJob?.cancel()
            volumeNormalizationJob?.cancel()
            sponsorBlockJob?.cancel()
            coroutineScope.cancel()
            glyphInterface.close()
        }
        super.onDestroy()
    }

    override fun shouldBeInvincible() = isPlayerStackInitialized && !playerInternal.shouldBePlaying

    override fun onConfigurationChanged(newConfig: Configuration) {
        handler.post {
            if (!isPlayerStackInitialized) return@post
            if (!bitmapProvider.setDefaultBitmap() || playerInternal.currentMediaItem == null) return@post
            updateNotification()
        }
        super.onConfigurationChanged(newConfig)
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        if (!isPlayerStackInitialized) {
            super.onTaskRemoved(rootIntent)
            return
        }
        if (!player.shouldBePlaying || PlayerPreferences.stopWhenClosed)
            broadcastPendingIntent<NotificationDismissReceiver>().send()
        super.onTaskRemoved(rootIntent)
    }

    private fun ensurePlayerStackInitialized() {
        if (isPlayerStackInitialized) return
        if (handler.looper.thread !== Thread.currentThread()) {
            val latch = CountDownLatch(1)
            handler.post { try { ensurePlayerStackInitialized() } finally { latch.countDown() } }
            try { latch.await() } catch (_: InterruptedException) { Thread.currentThread().interrupt() }
            return
        }
        synchronized(initLock) {
            if (isPlayerStackInitialized) return
            initializePlayerStackOnMain()
        }
    }

    private fun initializePlayerStackOnMain() {
        cacheInternal = createCache(this)
        playerInternal = ExoPlayer.Builder(this, createRendersFactory(), createMediaSourceFactory(cacheInternal))
            .setHandleAudioBecomingNoisy(true)
            .setWakeMode(C.WAKE_MODE_LOCAL)
            .setAudioAttributes(
                AudioAttributes.Builder().setUsage(C.USAGE_MEDIA).setContentType(C.AUDIO_CONTENT_TYPE_MUSIC).build(),
                PlayerPreferences.handleAudioFocus
            )
            .setUsePlatformDiagnostics(false)
            .build()
            .apply {
                skipSilenceEnabled = PlayerPreferences.skipSilence
                addListener(this@PlayerService)
                addAnalyticsListener(PlaybackStatsListener(false, this@PlayerService))
            }

        updateRepeatMode()

        mediaSessionInternal = MediaSession(baseContext, TAG).apply {
            setCallback(SessionCallback())
            setPlaybackState(stateBuilder.build())
            setSessionActivity(activityPendingIntent<MainActivity>())
            isActive = true
        }

        isPlayerStackInitialized = true

        coroutineScope.launch {
            var first = true
            combine(mediaItemState, isLikedState) { mediaItem, _ ->
                if (first) { first = false; return@combine }
                if (mediaItem == null) return@combine
                withContext(Dispatchers.Main) {
                    updatePlaybackState()
                    updateNotification()
                }
            }.collect()
        }

        maybeRestorePlayerQueue()
        maybeResumePlaybackWhenDeviceConnected()
        startPreferenceUpdater()
    }

    private fun startPreferenceUpdater() {
        preferenceUpdaterJob = coroutineScope.launch {
            fun <T : Any> subscribe(prop: SharedPreferencesProperty<T>, callback: (T) -> Unit) =
                launch { prop.stateFlow.collectLatest { handler.post { callback(it) } } }

            subscribe(AppearancePreferences.isShowingThumbnailInLockscreenProperty) { maybeShowSongCoverInLockScreen() }
            subscribe(PlayerPreferences.bassBoostLevelProperty) { maybeBassBoost() }
            subscribe(PlayerPreferences.bassBoostProperty) { maybeBassBoost() }
            subscribe(PlayerPreferences.reverbProperty) { maybeReverb() }
            subscribe(PlayerPreferences.isInvincibilityEnabledProperty) { this@PlayerService.isInvincibilityEnabled = it }
            subscribe(PlayerPreferences.pitchProperty) { player.setPlaybackPitch(it.coerceAtLeast(0.01f)) }
            subscribe(PlayerPreferences.queueLoopEnabledProperty) { updateRepeatMode() }
            subscribe(PlayerPreferences.resumePlaybackWhenDeviceConnectedProperty) { maybeResumePlaybackWhenDeviceConnected() }
            subscribe(PlayerPreferences.skipSilenceProperty) { player.skipSilenceEnabled = it }
            subscribe(PlayerPreferences.speedProperty) { player.setPlaybackSpeed(it.coerceAtLeast(0.01f)) }
            subscribe(PlayerPreferences.trackLoopEnabledProperty) { updateRepeatMode(); updateNotification() }
            subscribe(PlayerPreferences.volumeNormalizationBaseGainProperty) { maybeNormalizeVolume() }
            subscribe(PlayerPreferences.volumeNormalizationProperty) { maybeNormalizeVolume() }
            subscribe(PlayerPreferences.sponsorBlockEnabledProperty) { maybeSponsorBlock() }
            subscribe(PlayerPreferences.autoDownloadAtHalfProperty) { if (!it) autoDownloadedSongs.clear() }

            launch {
                while (isActive) {
                    val autoDownloadsEnabled = PlayerPreferences.autoDownloadAtHalf
                    val playbackSnapshot = withContext(Dispatchers.Main) {
                        Triple(player.shouldBePlaying, player.currentMediaItem?.mediaId, player.duration)
                    }
                    if (autoDownloadsEnabled && playbackSnapshot.first && playbackSnapshot.second != null) {
                        runCatching { maybeAutoDownload() }.onFailure { Log.e(TAG, "Error in auto-download check", it) }
                        delay(5_000)
                    } else {
                        delay(if (autoDownloadsEnabled) 10_000 else 60_000)
                    }
                }
            }

            launch {
                val audioManager = getSystemService<AudioManager>()
                val stream = AudioManager.STREAM_MUSIC
                val min = if (audioManager != null && isAtLeastAndroid9) audioManager.getStreamMinVolume(stream) else 0
                streamVolumeFlow(stream).collectLatest {
                    if (PlayerPreferences.stopOnMinimumVolume && it == min) handler.post(player::pause)
                }
            }
        }
    }

    private fun updateRepeatMode() {
        if (!isPlayerStackInitialized) return
        playerInternal.repeatMode = when {
            PlayerPreferences.trackLoopEnabled -> Player.REPEAT_MODE_ONE
            PlayerPreferences.queueLoopEnabled -> Player.REPEAT_MODE_ALL
            else -> Player.REPEAT_MODE_OFF
        }
    }

    override fun onPlaybackStatsReady(eventTime: AnalyticsListener.EventTime, playbackStats: PlaybackStats) {
        val totalPlayTimeMs = playbackStats.totalPlayTimeMs
        if (totalPlayTimeMs < 5000) return
        val mediaItem = eventTime.timeline[eventTime.windowIndex].mediaItem

        if (!DataPreferences.pausePlaytime) query {
            runCatching { Database.incrementTotalPlayTimeMs(mediaItem.mediaId, totalPlayTimeMs) }
        }
        if (!DataPreferences.pauseHistory) query {
            runCatching { Database.insert(Event(songId = mediaItem.mediaId, timestamp = System.currentTimeMillis(), playTime = totalPlayTimeMs)) }
        }
    }

    override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
        if (AppearancePreferences.hideExplicit && mediaItem?.mediaMetadata?.extras?.songBundle?.explicit == true) {
            player.forceSeekToNext()
            return
        }

        mediaItemState.update { mediaItem }

        if (reason == Player.MEDIA_ITEM_TRANSITION_REASON_AUTO || reason == Player.MEDIA_ITEM_TRANSITION_REASON_SEEK) {
            val currentId = mediaItem?.mediaId
            if (autoDownloadedSongs.size > 10) {
                val recentSongs = autoDownloadedSongs.toList().takeLast(5).toMutableSet()
                autoDownloadedSongs.clear()
                autoDownloadedSongs.addAll(recentSongs)
            }
            currentId?.let {
                retryAttempts.remove(it)
                if (retryAttempts.size > 3) {
                    val recentRetries = retryAttempts.toList().takeLast(3).toMap()
                    retryAttempts.clear()
                    retryAttempts.putAll(recentRetries)
                }
            }
            currentRetryJob?.cancel()
        }

        updateTemporalCache()
        maybeRecoverPlaybackError()
        maybeNormalizeVolume()
        maybeProcessRadio()

        with(bitmapProvider) {
            when {
                mediaItem == null -> load(null)
                mediaItem.mediaMetadata.artworkUri == lastUri -> bitmapProvider.load(lastUri)
            }
        }

        if (reason == Player.MEDIA_ITEM_TRANSITION_REASON_AUTO || reason == Player.MEDIA_ITEM_TRANSITION_REASON_SEEK)
            updateMediaSessionQueue(player.currentTimeline)
    }

    override fun onTimelineChanged(timeline: Timeline, reason: Int) {
        if (reason != Player.TIMELINE_CHANGE_REASON_PLAYLIST_CHANGED) return
        updateMediaSessionQueue(timeline)
        maybeSavePlayerQueue()
        updateTemporalCache()
    }

    override fun onPlayerError(error: PlaybackException) {
        val mediaItem = player.currentMediaItem
        val mediaId = mediaItem?.mediaId ?: ""
        val attempts = retryAttempts.getOrDefault(mediaId, 0)
        
        Log.e(TAG, "PlaybackError (attempt ${attempts + 1}/$maxRetries): ${error.errorCode}", error)
        
        if (shouldRetryPlayback(error)) {
            handleIntelligentRetry(error)
            return
        }

        val userFriendlyError = if (BuildConfig.DEBUG) "Code:${error.errorCode} ${error.message}" else error.message ?: "Unknown"
        toast(getString(R.string.playback_error, if (attempts > 0) "$userFriendlyError ($attempts/$maxRetries)" else userFriendlyError))

        super.onPlayerError(error)

        if (error.findCause<InvalidResponseCodeException>()?.responseCode == 416) {
            player.pause()
            player.prepare()
            player.play()
            return
        }

        if (!PlayerPreferences.skipOnError || !player.hasNextMediaItem()) return

        val prev = player.currentMediaItem ?: return
        player.seekToNextMediaItem()

        ServiceNotifications.autoSkip.sendNotification(this) {
            this.setSmallIcon(R.drawable.app_icon)
                .setCategory(NotificationCompat.CATEGORY_ERROR)
                .setOnlyAlertOnce(false)
                .setContentIntent(activityPendingIntent<MainActivity>())
                .setContentText(prev.mediaMetadata.title?.let { getString(R.string.skip_on_error_notification, it) } ?: getString(R.string.skip_on_error_notification_unknown_song))
                .setContentTitle(getString(R.string.skip_on_error))
        }
    }

    private fun updateTemporalCache() {
        runCatching {
            val currentIndex = player.currentMediaItemIndex
            val currentItem = player.currentMediaItem
            val nextItem = if (currentIndex + 1 < player.mediaItemCount) player.getMediaItemAt(currentIndex + 1) else null
            temporalCache.updateCurrentAndNext(currentItem?.mediaId, nextItem?.mediaId, cache)
        }
    }

    private fun isNetworkConnected(): Boolean {
        return runCatching {
            val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val net = cm.activeNetwork ?: return false
            val caps = cm.getNetworkCapabilities(net) ?: return false
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) || caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) || caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
        }.getOrDefault(false)
    }

    private fun shouldRetryPlayback(error: PlaybackException): Boolean {
        val mediaId = player.currentMediaItem?.mediaId ?: return false
        if (mediaId.startsWith(LOCAL_KEY_PREFIX)) return false
        if (retryAttempts.getOrDefault(mediaId, 0) >= maxRetries) return false
        
        return error.findCause<java.net.UnknownHostException>() != null ||
               error.findCause<java.net.SocketTimeoutException>() != null ||
               error.findCause<java.net.ConnectException>() != null ||
               error.findCause<javax.net.ssl.SSLException>() != null ||
               error.findCause<InvalidResponseCodeException>()?.let { it.responseCode in listOf(500, 502, 503, 504, 429, 403, 404, 410, 412) } == true ||
               error.errorCode in listOf(
                   PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED,
                   PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT,
                   PlaybackException.ERROR_CODE_IO_READ_POSITION_OUT_OF_RANGE,
                   PlaybackException.ERROR_CODE_IO_UNSPECIFIED,
                   PlaybackException.ERROR_CODE_IO_INVALID_HTTP_CONTENT_TYPE,
                   PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS,
                   PlaybackException.ERROR_CODE_PARSING_CONTAINER_MALFORMED,
                   PlaybackException.ERROR_CODE_PARSING_MANIFEST_MALFORMED
               ) ||
               error.message?.let { msg ->
                   listOf("youtube", "source", "stream", "network", "connection", "timeout").any { msg.contains(it, true) }
               } == true
    }

    private fun handleIntelligentRetry(error: PlaybackException) {
        val mediaItem = player.currentMediaItem ?: return
        val mediaId = mediaItem.mediaId
        currentRetryJob?.cancel()
        
        val attempts = retryAttempts.getOrDefault(mediaId, 0) + 1
        retryAttempts[mediaId] = attempts
        
        if (!isNetworkConnected()) {
            scheduleRetryWithNetworkCheck(mediaItem, attempts, retryDelayMs * 3)
            return
        }
        
        currentRetryJob = coroutineScope.launch {
            try {
                val delay = if (attempts == 1) 200L else retryDelayMs * attempts
                delay(delay)
                
                if (!isActive || currentPlayerMediaId() != mediaId) return@launch
                if (!isNetworkConnected()) {
                    delay(10000)
                    if (!isActive || currentPlayerMediaId() != mediaId) return@launch
                }
                
                withContext(Dispatchers.Main) {
                    try {
                        if (attempts == 1) {
                            val wasPlaying = player.isPlaying
                            player.pause()
                            delay(100)
                            if (player.playWhenReady || wasPlaying) player.play()
                        } else {
                            player.pause()
                            player.prepare()
                            delay(500)
                            if (player.playWhenReady) player.play()
                        }
                    } catch (e: Exception) {
                        if (attempts >= maxRetries) handleFinalError(error, mediaItem)
                    }
                }
            } catch (e: Exception) {
                if (e !is kotlinx.coroutines.CancellationException) Log.e(TAG, "Error in retry job", e)
            }
        }
    }

    private suspend fun currentPlayerMediaId(): String? = withContext(Dispatchers.Main) { player.currentMediaItem?.mediaId }

    private fun scheduleRetryWithNetworkCheck(mediaItem: MediaItem, attempts: Int, delayMs: Long) {
        currentRetryJob = coroutineScope.launch {
            try {
                val startTime = System.currentTimeMillis()
                val maxWaitTime = delayMs * 2
                val targetId = mediaItem.mediaId
                
                while (!isNetworkConnected() && (System.currentTimeMillis() - startTime) < maxWaitTime && isActive && currentPlayerMediaId() == targetId) {
                    delay(2000)
                }
                
                if (!isActive || currentPlayerMediaId() != targetId) return@launch
                
                withContext(Dispatchers.Main) {
                    if (isNetworkConnected()) {
                        handleIntelligentRetry(PlaybackException("Network reconnected", null, PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED))
                    } else {
                        handleFinalError(PlaybackException("Network timeout", null, PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT), mediaItem)
                    }
                }
            } catch (e: Exception) {
                if (e !is kotlinx.coroutines.CancellationException) Log.e(TAG, "Error in network check retry", e)
            }
        }
    }

    private fun handleFinalError(error: PlaybackException, mediaItem: MediaItem) {
        val detailed = error.message ?: error::class.simpleName ?: "Unknown"
        toast(getString(R.string.playback_error, "$detailed (reintentos agotados)"))
        retryAttempts.remove(mediaItem.mediaId)
        
        if (PlayerPreferences.skipOnError && player.hasNextMediaItem()) {
            player.seekToNextMediaItem()
            ServiceNotifications.autoSkip.sendNotification(this) {
                this.setSmallIcon(R.drawable.app_icon)
                    .setCategory(NotificationCompat.CATEGORY_ERROR)
                    .setOnlyAlertOnce(false)
                    .setContentIntent(activityPendingIntent<MainActivity>())
                    .setContentText(getString(R.string.skip_on_error_notification, mediaItem.mediaMetadata.title ?: "Unknown"))
                    .setContentTitle(getString(R.string.skip_on_error))
            }
        }
    }

    private fun updateMediaSessionQueue(timeline: Timeline) {
        val builder = MediaDescription.Builder()
        val currentMediaItemIndex = player.currentMediaItemIndex
        val lastIndex = timeline.windowCount - 1
        var startIndex = (currentMediaItemIndex - 7).coerceAtLeast(0)
        var endIndex = (currentMediaItemIndex + 7).coerceAtMost(lastIndex)

        mediaSession.setQueue(
            List(endIndex - startIndex + 1) { index ->
                val mediaItem = timeline.getWindow(index + startIndex, Timeline.Window()).mediaItem
                MediaSession.QueueItem(
                    builder.setMediaId(mediaItem.mediaId)
                        .setTitle(mediaItem.mediaMetadata.title)
                        .setSubtitle(mediaItem.mediaMetadata.artist)
                        .setIconUri(mediaItem.mediaMetadata.artworkUri)
                        .build(),
                    (index + startIndex).toLong()
                )
            }
        )
    }

    private fun maybeRecoverPlaybackError() {
        if (player.playerError != null) player.prepare()
    }

    private fun maybeProcessRadio() {
        if (!PlayerPreferences.autoPlayRecommendations || player.repeatMode == Player.REPEAT_MODE_ONE) return
        val currentItem = player.currentMediaItem ?: return
        val currentIndex = player.currentMediaItemIndex.takeIf { it != C.INDEX_UNSET } ?: 0
        val remainingAhead = (player.mediaItemCount - (currentIndex + 1)).coerceAtLeast(0)
        val shouldForceRestart = player.playbackState == Player.STATE_ENDED || player.mediaItemCount == 0
        
        if (!shouldForceRestart && remainingAhead > 2) return
        
        val currentId = currentItem.mediaId.takeIf { it.isNotBlank() } ?: return
        if (currentId.startsWith(LOCAL_KEY_PREFIX) || currentId.startsWith("download:") || binder.isLoadingRadio) return

        if (shouldForceRestart) binder.playRadio(currentId) else binder.setupRadio(currentId)
    }

    private fun maybeSavePlayerQueue() {
        if (!PlayerPreferences.persistentQueue) return
        val mediaItems = player.currentTimeline.mediaItems
        val mediaItemIndex = player.currentMediaItemIndex
        val mediaItemPosition = player.currentPosition

        transaction {
            runCatching {
                Database.clearQueue()
                Database.insert(
                    mediaItems.mapIndexed { index, mediaItem ->
                        QueuedMediaItem(mediaItem = mediaItem, position = if (index == mediaItemIndex) mediaItemPosition else null)
                    }
                )
            }
        }
    }

    private fun maybeRestorePlayerQueue() {
        if (!PlayerPreferences.persistentQueue) return
        transaction {
            val queue = Database.queue()
            if (queue.isEmpty()) return@transaction
            Database.clearQueue()
            val index = queue.indexOfFirst { it.position != null }.coerceAtLeast(0)

            handler.post {
                runCatching {
                    player.setMediaItems(
                        queue.map { item ->
                            item.mediaItem.buildUpon().setUri(item.mediaItem.mediaId).setCustomCacheKey(item.mediaItem.mediaId).build().apply {
                                mediaMetadata.extras?.songBundle?.apply { isFromPersistentQueue = true }
                            }
                        },
                        index,
                        queue[index].position ?: C.TIME_UNSET
                    )
                    player.prepare()
                    isNotificationStarted = true
                    startForeground()
                }
            }
        }
    }

    private fun maybeNormalizeVolume() {
        if (!PlayerPreferences.volumeNormalization) {
            loudnessEnhancer?.enabled = false
            loudnessEnhancer?.release()
            loudnessEnhancer = null
            volumeNormalizationJob?.cancel()
            player.volume = 1f
            return
        }

        runCatching { if (loudnessEnhancer == null) loudnessEnhancer = LoudnessEnhancer(player.audioSessionId) }.onFailure { return }
        val songId = player.currentMediaItem?.mediaId ?: return
        volumeNormalizationJob?.cancel()
        volumeNormalizationJob = coroutineScope.launch {
            runCatching {
                fun Float?.toMb() = ((this ?: 0f) * 100).toInt()
                Database.loudnessDb(songId).cancellable().collectLatest { loudness ->
                    val loudnessMb = loudness.toMb().let { if (it !in -2000..2000) 0 else it }
                    Database.loudnessBoost(songId).cancellable().collectLatest { boost ->
                        withContext(Dispatchers.Main) {
                            loudnessEnhancer?.setTargetGain(PlayerPreferences.volumeNormalizationBaseGain.toMb() + boost.toMb() - loudnessMb)
                            loudnessEnhancer?.enabled = true
                        }
                    }
                }
            }
        }
    }

    private fun maybeSponsorBlock() {
        poiTimestamp = null
        if (!PlayerPreferences.sponsorBlockEnabled) {
            sponsorBlockJob?.cancel()
            return
        }

        sponsorBlockJob?.cancel()
        sponsorBlockJob = coroutineScope.launch {
            mediaItemState.onStart { emit(mediaItemState.value) }.collectLatest { mediaItem ->
                poiTimestamp = null
                val videoId = mediaItem?.mediaId?.removePrefix("https://youtube.com/watch?v=")?.takeIf { it.isNotBlank() } ?: return@collectLatest

                SponsorBlock.segments(videoId)?.onSuccess { segments ->
                    poiTimestamp = segments.find { it.category == Category.PoiHighlight }?.start?.inWholeMilliseconds
                }?.map { segments ->
                    segments.sortedBy { it.start.inWholeMilliseconds }.filter { it.action == Action.Skip }
                }?.mapCatching { segments ->
                    val ctx = currentCoroutineContext()
                    val lastSegmentEnd = segments.lastOrNull()?.end?.inWholeMilliseconds ?: return@mapCatching

                    while (ctx.isActive) {
                        val pos = withContext(Dispatchers.Main) { player.currentPosition }
                        if (lastSegmentEnd < pos) { yield(); continue }

                        val nextSegment = segments.firstOrNull { pos < it.end.inWholeMilliseconds } ?: continue
                        if (nextSegment.start.inWholeMilliseconds > pos) {
                            val speed = withContext(Dispatchers.Main) { player.playbackParameters.speed.toDouble() }
                            delay(((nextSegment.start.inWholeMilliseconds - pos) / speed).milliseconds)
                        }

                        val currentPos = withContext(Dispatchers.Main) { player.currentPosition }
                        if (currentPos.milliseconds in nextSegment.start..nextSegment.end) {
                            withContext(Dispatchers.Main) { player.seekTo(nextSegment.end.inWholeMilliseconds) }
                        }
                        yield()
                    }
                }
            }
        }
    }

    private fun maybeBassBoost() {
        if (!PlayerPreferences.bassBoost) {
            runCatching { bassBoost?.enabled = false; bassBoost?.release() }
            bassBoost = null
            maybeNormalizeVolume()
            return
        }
        runCatching {
            if (bassBoost == null) bassBoost = BassBoost(0, player.audioSessionId)
            bassBoost?.setStrength(PlayerPreferences.bassBoostLevel.toShort())
            bassBoost?.enabled = true
        }.onFailure { toast(getString(R.string.error_bassboost_init)) }
    }

    private fun maybeReverb() {
        if (PlayerPreferences.reverb == PlayerPreferences.Reverb.None) {
            runCatching { reverb?.enabled = false; player.clearAuxEffectInfo(); reverb?.release() }
            reverb = null
            return
        }
        runCatching {
            if (reverb == null) reverb = PresetReverb(1, player.audioSessionId)
            reverb?.preset = PlayerPreferences.reverb.preset
            reverb?.enabled = true
            reverb?.id?.let { player.setAuxEffectInfo(AuxEffectInfo(it, 1f)) }
        }
    }

    private fun maybeShowSongCoverInLockScreen() = handler.post {
        val bitmap = if (isAtLeastAndroid13 || AppearancePreferences.isShowingThumbnailInLockscreen) bitmapProvider.bitmap else null
        val uri = player.mediaMetadata.artworkUri?.toString()?.thumbnail(512)
        metadataBuilder.putBitmap(MediaMetadata.METADATA_KEY_ART, bitmap)
        metadataBuilder.putString(MediaMetadata.METADATA_KEY_ART_URI, uri)
        metadataBuilder.putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, bitmap)
        metadataBuilder.putString(MediaMetadata.METADATA_KEY_ALBUM_ART_URI, uri)
        if (isAtLeastAndroid13 && player.currentMediaItemIndex == 0) metadataBuilder.putText(MediaMetadata.METADATA_KEY_TITLE, "${player.mediaMetadata.title} ")
        mediaSession.setMetadata(metadataBuilder.build())
    }

    private fun maybeAutoDownload() {
        handler.post {
            runCatching {
                if (!PlayerPreferences.autoDownloadAtHalf) return@post
                val currentMediaItem = player.currentMediaItem ?: return@post
                val mediaId = currentMediaItem.mediaId
                if (mediaId.isBlank() || mediaId in autoDownloadedSongs || mediaId.startsWith(LOCAL_KEY_PREFIX) || mediaId.startsWith("download:")) return@post
                
                val duration = player.duration
                val position = player.currentPosition
                
                if (duration > 0 && duration != C.TIME_UNSET && position >= duration / 2) {
                    if (!hasAvailableStorage()) {
                        PlayerPreferences.autoDownloadAtHalf = false
                        handler.post { toast(getString(R.string.auto_download_disabled_storage_full)) }
                        autoDownloadedSongs.add(mediaId)
                        return@post
                    }
                    
                    autoDownloadedSongs.add(mediaId)
                    coroutineScope.launch(Dispatchers.IO) {
                        if (Database.downloadedSongById("download:$mediaId") != null) return@launch
                        
                        val interProvider = IntermusicProvider.shared()
                        val streamingUrl = runCatching { interProvider.getBestAudioStream(mediaId).getOrNull()?.url }.getOrNull() 
                            ?: runCatching { interProvider.getStreamUrl(mediaId).getOrNull() }.getOrNull()
                        
                        if (streamingUrl != null) {
                            lastProviderSource.value = "Intermusic"
                            MusicDownloadService.download(
                                context = this@PlayerService,
                                trackId = mediaId,
                                title = currentMediaItem.mediaMetadata.title?.toString() ?: "Unknown",
                                artist = currentMediaItem.mediaMetadata.artist?.toString(),
                                album = currentMediaItem.mediaMetadata.albumTitle?.toString(),
                                thumbnailUrl = currentMediaItem.mediaMetadata.artworkUri?.toString(),
                                duration = if (duration > 0 && duration != C.TIME_UNSET) duration else null,
                                url = streamingUrl
                            )
                            withContext(Dispatchers.Main) { toast(getString(R.string.auto_download_started, currentMediaItem.mediaMetadata.title)) }
                        }
                    }
                }
            }
        }
    }

    private fun hasAvailableStorage(): Boolean {
        return runCatching {
            val stat = StatFs(applicationContext.filesDir.path)
            val totalBytes = stat.blockCountLong * stat.blockSizeLong
            val availableBytes = stat.availableBlocksLong * stat.blockSizeLong
            val usagePercentage = ((totalBytes - availableBytes).toDouble() / totalBytes.toDouble()) * 100
            usagePercentage < 95.0
        }.getOrDefault(true)
    }

    private fun maybeResumePlaybackWhenDeviceConnected() {
        if (!isAtLeastAndroid6 || !isPlayerStackInitialized) return
        if (!PlayerPreferences.resumePlaybackWhenDeviceConnected) {
            audioManager?.unregisterAudioDeviceCallback(audioDeviceCallback)
            audioDeviceCallback = null
            return
        }
        if (audioManager == null) audioManager = getSystemService<AudioManager>()
        audioDeviceCallback = object : AudioDeviceCallback() {
            private fun canPlayMusic(audioDeviceInfo: AudioDeviceInfo) = audioDeviceInfo.isSink && 
                (audioDeviceInfo.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP || audioDeviceInfo.type == AudioDeviceInfo.TYPE_WIRED_HEADSET || audioDeviceInfo.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES || (isAtLeastAndroid8 && audioDeviceInfo.type == AudioDeviceInfo.TYPE_USB_HEADSET))
            override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
                if (!player.isPlaying && addedDevices.any(::canPlayMusic)) player.play()
            }
        }
        audioManager?.registerAudioDeviceCallback(audioDeviceCallback, handler)
    }

    private fun openEqualizer() = EqualizerIntentBundleAccessor.sendOpenEqualizer(player.audioSessionId)
    private fun closeEqualizer() = EqualizerIntentBundleAccessor.sendCloseEqualizer(player.audioSessionId)

    private fun updatePlaybackState() = coroutineScope.launch {
        playbackStateMutex.withLock {
            withContext(Dispatchers.Main) {
                mediaSession.setPlaybackState(
                    stateBuilder.setState(player.androidPlaybackState, player.currentPosition, player.playbackParameters.speed, SystemClock.elapsedRealtime())
                        .setBufferedPosition(player.bufferedPosition)
                        .build()
                )
            }
        }
    }

    private val Player.androidPlaybackState get() = when (playbackState) {
        Player.STATE_BUFFERING -> if (playWhenReady) PlaybackState.STATE_BUFFERING else PlaybackState.STATE_PAUSED
        Player.STATE_READY -> if (playWhenReady) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
        Player.STATE_ENDED -> PlaybackState.STATE_STOPPED
        Player.STATE_IDLE -> PlaybackState.STATE_NONE
        else -> PlaybackState.STATE_NONE
    }

    @Suppress("DEPRECATION")
    override fun onEvents(player: Player, events: Player.Events) {
        if (player.duration != C.TIME_UNSET) mediaSession.setMetadata(
            metadataBuilder
                .putText(MediaMetadata.METADATA_KEY_TITLE, player.mediaMetadata.title?.toString().orEmpty())
                .putText(MediaMetadata.METADATA_KEY_ARTIST, player.mediaMetadata.artist?.toString().orEmpty())
                .putText(MediaMetadata.METADATA_KEY_ALBUM, player.mediaMetadata.albumTitle?.toString().orEmpty())
                .putLong(MediaMetadata.METADATA_KEY_DURATION, player.duration)
                .build()
        )
        updatePlaybackState()

        if (!events.containsAny(Player.EVENT_PLAYBACK_STATE_CHANGED, Player.EVENT_PLAY_WHEN_READY_CHANGED, Player.EVENT_IS_PLAYING_CHANGED, Player.EVENT_POSITION_DISCONTINUITY, Player.EVENT_IS_LOADING_CHANGED, Player.EVENT_MEDIA_METADATA_CHANGED)) return

        val notification = notification()
        if (notification == null) {
            isNotificationStarted = false
            makeInvincible(false)
            stopForeground(false)
            closeEqualizer()
            ServiceNotifications.default.cancel(this)
            return
        }

        if (player.shouldBePlaying && !isNotificationStarted) {
            isNotificationStarted = true
            startForeground()
            makeInvincible(false)
            openEqualizer()
        } else {
            if (!player.shouldBePlaying) {
                isNotificationStarted = false
                stopForeground(false)
                makeInvincible(true)
                closeEqualizer()
            }
            updateNotification()
        }

        if (events.contains(Player.EVENT_PLAYBACK_STATE_CHANGED) && player.playbackState == Player.STATE_ENDED) {
            maybeProcessRadio()
        }
    }

    private fun notification(): (NotificationCompat.Builder.() -> NotificationCompat.Builder)? {
        if (!isPlayerStackInitialized || player.currentMediaItem == null) return null
        val mediaMetadata = player.mediaMetadata
        bitmapProvider.load(mediaMetadata.artworkUri) { maybeShowSongCoverInLockScreen(); updateNotification() }

        return {
            setContentTitle(mediaMetadata.title?.toString().orEmpty())
                .setContentText(mediaMetadata.artist?.toString().orEmpty())
                .setSubText(player.playerError?.message)
                .setLargeIcon(bitmapProvider.bitmap)
                .setAutoCancel(false)
                .setOnlyAlertOnce(true)
                .setShowWhen(false)
                .setSmallIcon(player.playerError?.let { R.drawable.alert_circle } ?: R.drawable.app_icon)
                .setOngoing(false)
                .setContentIntent(activityPendingIntent<MainActivity>(flags = PendingIntent.FLAG_UPDATE_CURRENT))
                .setDeleteIntent(broadcastPendingIntent<NotificationDismissReceiver>())
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
                .addAction(R.drawable.play_skip_back, getString(R.string.skip_back), notificationActionReceiver.previous.pendingIntent)
                .let { if (player.shouldBePlaying) it.addAction(R.drawable.pause, getString(R.string.pause), notificationActionReceiver.pause.pendingIntent) else it.addAction(R.drawable.play, getString(R.string.play), notificationActionReceiver.play.pendingIntent) }
                .addAction(R.drawable.play_skip_forward, getString(R.string.skip_forward), notificationActionReceiver.next.pendingIntent)
                .addAction(if (isLikedState.value) R.drawable.heart else R.drawable.heart_outline, getString(R.string.like), notificationActionReceiver.like.pendingIntent)
                .addAction(if (PlayerPreferences.trackLoopEnabled) R.drawable.repeat_on else R.drawable.repeat, getString(R.string.queue_loop), notificationActionReceiver.loop.pendingIntent)
                .setStyle(androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1, 2).setMediaSession(MediaSessionCompat.Token.fromToken(mediaSession.sessionToken)))
        }
    }

    private fun updateNotification() = runCatching {
        if (!isPlayerStackInitialized) return@runCatching
        handler.post { notification()?.let { ServiceNotifications.default.sendNotification(this, it) } }
    }

    override fun startForeground() {
        if (!isPlayerStackInitialized) return
        notification()?.let { ServiceNotifications.default.startForeground(this, it) }
    }

    private fun createMediaSourceFactory(resolvedCache: Cache): DefaultMediaSourceFactory {
        val uriCache = UriCache<String, Long?>()
        return DefaultMediaSourceFactory(
            createYouTubeDataSourceResolverFactory(
                context = applicationContext,
                cache = resolvedCache,
                findMediaItem = { videoId -> withContext(Dispatchers.Main) { player.findNextMediaItemById(videoId) } },
                uriCache = uriCache,
                onProviderUsed = { source -> lastProviderSource.value = source }
            ),
            DefaultExtractorsFactory()
        ).setLoadErrorHandlingPolicy(
            object : DefaultLoadErrorHandlingPolicy() {
                override fun isEligibleForFallback(exception: IOException) = true
                override fun getRetryDelayMsFor(loadErrorInfo: LoadErrorHandlingPolicy.LoadErrorInfo): Long {
                    val exception = loadErrorInfo.exception
                    val dataSpec = loadErrorInfo.loadEventInfo.dataSpec
                    val key = dataSpec?.key

                    if (exception is InvalidResponseCodeException && exception.responseCode == 403) {
                        Log.w(TAG, "Resolver:clearing entire URI cache due to HTTP 403")
                        uriCache.clear()
                    } else if (!key.isNullOrEmpty() && !key.startsWith(LOCAL_KEY_PREFIX)) {
                        if (exception.findCause<EOFException>() != null || exception.findCause<UnexpectedLoaderException>() != null || exception.findCause<ArrayIndexOutOfBoundsException>() != null) {
                            uriCache.remove(key)
                            Log.w(TAG, "Resolver:evicted cached URI for $key after ${exception.javaClass.simpleName}")
                        }
                    }
                    return super.getRetryDelayMsFor(loadErrorInfo)
                }
            }
        )
    }

    private fun createRendersFactory() = object : DefaultRenderersFactory(this) {
        override fun buildAudioSink(context: Context, enableFloatOutput: Boolean, enableAudioTrackPlaybackParams: Boolean): AudioSink {
            val minimumSilenceDuration = PlayerPreferences.minimumSilence.coerceIn(1000L..2_000_000L)
            return DefaultAudioSink.Builder(applicationContext)
                .setEnableFloatOutput(enableFloatOutput)
                .setEnableAudioTrackPlaybackParams(enableAudioTrackPlaybackParams)
                .setAudioOffloadSupportProvider(DefaultAudioOffloadSupportProvider(applicationContext))
                .setAudioProcessorChain(DefaultAudioSink.DefaultAudioProcessorChain(arrayOf(), SilenceSkippingAudioProcessor(minimumSilenceDuration, 0.01f, minimumSilenceDuration, 0, 256), SonicAudioProcessor()))
                .build().apply { if (isAtLeastAndroid10) setOffloadMode(AudioSink.OFFLOAD_MODE_DISABLED) }
        }
    }

    @Stable
    inner class Binder : AndroidBinder() {
        val player: ExoPlayer get() = this@PlayerService.player
        val streamProviderSource: StateFlow<String> get() = this@PlayerService.lastProviderSource
        val cache: Cache get() = this@PlayerService.cache
        val mediaSession get() = this@PlayerService.mediaSession
        val sleepTimerMillisLeft: StateFlow<Long?>? get() = timerJob?.millisLeft
        val poiTimestamp get() = this@PlayerService.poiTimestamp
        
        var isLoadingRadio by mutableStateOf(false); private set
        var invincible get() = isInvincibilityEnabled; set(value) { isInvincibilityEnabled = value }
        private var radioJob: Job? = null

        fun setBitmapListener(listener: ((Bitmap?) -> Unit)?) = bitmapProvider.setListener(listener)

        @kotlin.OptIn(FlowPreview::class)
        fun startSleepTimer(delayMillis: Long) {
            timerJob?.cancel()
            timerJob = coroutineScope.timer(delayMillis) {
                ServiceNotifications.sleepTimer.sendNotification(this@PlayerService) {
                    setContentTitle(getString(R.string.sleep_timer_ended)).setPriority(NotificationCompat.PRIORITY_DEFAULT).setAutoCancel(true).setOnlyAlertOnce(true).setShowWhen(true).setSmallIcon(R.drawable.app_icon)
                }
                handler.post { player.pause(); player.stop(); glyphInterface.glyph { turnOff() } }
            }.also { job ->
                glyphInterface.progress(job.millisLeft.takeWhile { it != null }.debounce(500.milliseconds).map { ((it ?: 0L) / delayMillis.toFloat() * 100).toInt() })
            }
        }

        fun cancelSleepTimer() { timerJob?.cancel(); timerJob = null }
        fun setupRadio(videoId: String?) = startRadio(videoId = videoId, justAdd = true)
        fun playRadio(videoId: String?) = startRadio(videoId = videoId, justAdd = false)
        fun stopRadio() { isLoadingRadio = false; radioJob?.cancel(); radioJob = null }
        fun restartForegroundOrStop() { player.pause(); isInvincibilityEnabled = false; stopSelf() }
        fun isCached(song: SongWithContentLength) = song.contentLength?.let { cache.isCached(song.song.id, 0L, it) } ?: false

        fun playFromSearch(query: String) {
            coroutineScope.launch {
                val result = intermusicProvider.search(query, IntermusicProvider.SearchFilter.SONGS).getOrNull()
                val mediaItem = result?.songs?.firstOrNull()?.asMediaItem ?: return@launch
                playRadio(mediaItem.mediaId)
            }
        }

        private fun startRadio(videoId: String?, justAdd: Boolean) {
            radioJob?.cancel()
            if (videoId.isNullOrBlank()) { isLoadingRadio = false; if (!justAdd) stopRadio(); return }
            isLoadingRadio = true
            radioJob = coroutineScope.launch {
                try {
                    val items = fetchRadioItems(videoId).let { Database.filterBlacklistedSongs(it) }
                    withContext(Dispatchers.Main) {
                        if (items.isNotEmpty()) {
                            if (justAdd) {
                                val existingIds = player.currentTimeline.mediaItems.map { it.mediaId }.toSet()
                                val toAppend = items.drop(1).filter { it.mediaId !in existingIds }
                                if (toAppend.isNotEmpty()) player.addMediaItems(toAppend)
                            } else {
                                player.forcePlayFromBeginning(items)
                            }
                        }
                    }
                } catch (error: Exception) { Log.w(TAG, "Radio generation failed", error) } finally { isLoadingRadio = false }
            }
        }

        private suspend fun fetchRadioItems(videoId: String): List<MediaItem> {
            val provider = intermusicProvider
            val ordered = LinkedHashMap<String, MediaItem>()
            val seedResult = provider.getPlayer(videoId).getOrNull()
            seedResult?.asMediaItem?.let { ordered[it.mediaId] = it }
            provider.getWatchNextRadio(videoId).getOrNull()?.forEach { song -> val item = song.asMediaItem; ordered.putIfAbsent(item.mediaId, item) }
            val baseQuery = seedResult?.artists?.firstOrNull()?.name?.takeIf { it.isNotBlank() } ?: seedResult?.title?.takeIf { !it.isNullOrBlank() } ?: videoId
            provider.search(baseQuery, IntermusicProvider.SearchFilter.SONGS).getOrNull()?.songs.orEmpty().filter { it.videoId != videoId }.forEach { song -> val item = song.asMediaItem; ordered.putIfAbsent(item.mediaId, item) }
            return ordered.values.toList()
        }
    }

    private fun likeAction() = mediaItemState.value?.let { mediaItem ->
        query { runCatching { Database.like(songId = mediaItem.mediaId, likedAt = if (isLikedState.value) null else System.currentTimeMillis()) } }
    }.let { }

    private fun loopAction() { PlayerPreferences.trackLoopEnabled = !PlayerPreferences.trackLoopEnabled }

    private inner class SessionCallback : MediaSession.Callback() {
        override fun onPlay() = player.play()
        override fun onPause() = player.pause()
        override fun onSkipToPrevious() = runCatching(player::forceSeekToPrevious).let { }
        override fun onSkipToNext() = runCatching(player::forceSeekToNext).let { }
        override fun onSeekTo(pos: Long) = player.seekTo(pos)
        override fun onStop() = player.pause()
        override fun onRewind() = player.seekToDefaultPosition()
        override fun onSkipToQueueItem(id: Long) = runCatching { player.seekToDefaultPosition(id.toInt()) }.let { }
        override fun onSetPlaybackSpeed(speed: Float) { PlayerPreferences.speed = speed.coerceIn(0.01f..2f) }
        override fun onPlayFromSearch(query: String?, extras: Bundle?) { if (!query.isNullOrBlank()) binder.playFromSearch(query) }
        override fun onCustomAction(action: String, extras: Bundle?) {
            super.onCustomAction(action, extras)
            when (action) { LIKE_ACTION -> likeAction(); LOOP_ACTION -> loopAction() }
        }
    }

    inner class NotificationActionReceiver internal constructor() : ActionReceiver("com.rmusic.android") {
        val pause by action { _, _ -> player.pause() }
        val play by action { _, _ -> player.play() }
        val next by action { _, _ -> player.forceSeekToNext() }
        val previous by action { _, _ -> player.forceSeekToPrevious() }
        val like by action { _, _ -> likeAction() }
        val loop by action { _, _ -> loopAction() }
    }

    class NotificationDismissReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) { context.stopService(context.intent<PlayerService>()) }
    }

    private class TemporalSmartCache {
        private var currentSongId: String? = null
        private var nextSongId: String? = null
        private val cachedItems = mutableSetOf<String>()

        fun updateCurrentAndNext(current: String?, next: String?, cache: Cache) {
            cachedItems.filter { it != current && it != next && !it.startsWith(LOCAL_KEY_PREFIX) }.forEach {
                runCatching { cache.removeResource(it); cachedItems.remove(it) }
            }
            currentSongId = current; nextSongId = next
            current?.let { cachedItems.add(it) }; next?.let { cachedItems.add(it) }
        }

        fun clearAll(cache: Cache) {
            cachedItems.filter { !it.startsWith(LOCAL_KEY_PREFIX) }.forEach { runCatching { cache.removeResource(it) } }
            cachedItems.clear(); currentSongId = null; nextSongId = null
        }
    }

    companion object {
        private const val DEFAULT_CACHE_DIRECTORY = "exoplayer"
        private const val STREAM_URL_TTL_MS = 10 * 60 * 1000L

        fun createDatabaseProvider(context: Context) = StandaloneDatabaseProvider(context)
        fun createCache(context: Context, directoryName: String = DEFAULT_CACHE_DIRECTORY, size: ExoPlayerDiskCacheSize = DataPreferences.exoPlayerDiskCacheMaxSize) = with(context) {
            val effectiveSize = if (DeviceConstraints.disableDiskCache && size.bytes > ExoPlayerDiskCacheSize.`128MB`.bytes) ExoPlayerDiskCacheSize.`128MB` else size
            val cacheEvictor = if (effectiveSize == ExoPlayerDiskCacheSize.Unlimited) NoOpCacheEvictor() else LeastRecentlyUsedCacheEvictor(effectiveSize.bytes)
            val directory = cacheDir.resolve(directoryName).apply { if (!exists()) mkdir() }
            if (DeviceConstraints.disableDiskCache) { runCatching { directory.deleteRecursively() }; runCatching { directory.mkdirs() } }
            SimpleCache(directory, cacheEvictor, createDatabaseProvider(context))
        }

        @Suppress("CyclomaticComplexMethod")
        fun createYouTubeDataSourceResolverFactory(
            context: Context,
            cache: Cache,
            findMediaItem: suspend (videoId: String) -> MediaItem? = { null },
            uriCache: UriCache<String, Long?> = UriCache(),
            onProviderUsed: (String) -> Unit = {}
        ): DataSource.Factory {
            return ResolvingDataSource.Factory(
                ConditionalCacheDataSourceFactory(
                    cacheDataSourceFactory = cache.readOnlyWhen { PlayerPreferences.pauseCache }.asDataSource,
                    upstreamDataSourceFactory = context.youtubeDataSource,
                    shouldCache = { !it.isLocal }
                )
            ) resolver@{ dataSpec ->
                val rawKey = dataSpec.key ?: dataSpec.uri?.toString()
                val mediaId = rawKey?.removePrefix("https://youtube.com/watch?v=") ?: throw PlaybackException("Missing cache key", null, PlaybackException.ERROR_CODE_IO_UNSPECIFIED)

                fun DataSpec.withYouTubeRange(totalLength: Long?): DataSpec {
                    val start = dataSpec.position
                    val remaining = totalLength?.takeIf { it != C.LENGTH_UNSET.toLong() }?.let { total -> (total - start).takeIf { it > 0 } }
                    val targetLength = remaining ?: C.LENGTH_UNSET.toLong()
                    return this.subrange(0, targetLength)
                }

                if (dataSpec.isLocal) return@resolver dataSpec

                if (mediaId.startsWith("download:")) {
                    val downloadedSong = runBlocking(Dispatchers.IO) { Database.downloadedSongById(mediaId) }
                    if (downloadedSong != null && File(downloadedSong.filePath).exists()) {
                        return@resolver dataSpec.withUri(File(downloadedSong.filePath).toUri())
                    } else {
                        throw PlayableFormatNotFoundException()
                    }
                }

                uriCache[mediaId]?.let { cachedUri ->
                    return@resolver dataSpec.withUri(cachedUri.uri).withYouTubeRange(cachedUri.meta).ensureRangeHeader()
                }

                val interProvider = IntermusicProvider.shared()
                val best = runBlocking(Dispatchers.IO) { interProvider.getBestAudioStream(mediaId).getOrNull() }
                var directUrl = best?.url ?: runBlocking(Dispatchers.IO) { interProvider.getStreamUrl(mediaId).getOrNull() }

                var chosenUrl: String? = null
                var chosenBest: com.rmusic.providers.intermusic.IntermusicProvider.AudioStreamInfo? = null

                if (directUrl != null) {
                    if (runBlocking(Dispatchers.IO) { interProvider.testUrlAccess(directUrl!!).getOrDefault(false) }) {
                        chosenUrl = directUrl
                        chosenBest = best
                    }
                }

                if (chosenUrl != null) {
                    onProviderUsed("Intermusic")
                    val contentLen = runBlocking(Dispatchers.IO) { interProvider.headContentLength(chosenUrl!!).getOrNull() }
                    val best = chosenBest
                    runCatching {
                        if (best != null) transaction {
                            runCatching {
                                val item = runBlocking(Dispatchers.IO) { findMediaItem(mediaId) }
                                if (item != null) Database.insert(item) else Database.insert(Song(id = mediaId, title = mediaId, durationText = null, thumbnailUrl = null))
                            }
                            Database.insert(Format(songId = mediaId, itag = best.itag, mimeType = best.mimeType, bitrate = best.bitrate?.toLong(), contentLength = contentLen, lastModified = null, loudnessDb = best.loudnessDb, url = chosenUrl))
                        }
                    }

                    val uri = chosenUrl!!.toUri()
                    val expiresAt = Instant.fromEpochMilliseconds(System.currentTimeMillis() + STREAM_URL_TTL_MS)
                    uriCache.push(key = mediaId, meta = contentLen, uri = uri, validUntil = expiresAt)
                    return@resolver dataSpec.withUri(uri).withYouTubeRange(contentLen).ensureRangeHeader()
                }

                throw PlayableFormatNotFoundException()
            }.handleUnknownErrors {
                uriCache.clear()
            }.retryIf<UnplayableException>(maxRetries = 2, printStackTrace = true).retryIf(maxRetries = 1, printStackTrace = true) { ex ->
                ex.findCause<InvalidResponseCodeException>()?.responseCode == 403 || ex.findCause<ClientRequestException>()?.response?.status?.value == 403
            }.handleRangeErrors().withFallback(context) { dataSpec ->
                val id = dataSpec.key ?: error("No id found")
                val alternativeSong = runBlocking(Dispatchers.IO) { Database.songById(id) ?: Database.localSongsByRowIdDesc().first().find { id in it.title } } ?: error("No alternative song")
                dataSpec.buildUpon().setKey(alternativeSong.id).setUri(ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, alternativeSong.id.substringAfter(LOCAL_KEY_PREFIX).toLong())).build()
            }
        }
    }
}
