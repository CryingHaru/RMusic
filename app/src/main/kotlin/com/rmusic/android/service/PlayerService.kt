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
import android.text.format.DateUtils
import androidx.annotation.OptIn
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat.startForegroundService
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
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.requests.player
import com.rmusic.android.preferences.AppearancePreferences
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.preferences.PlayerPreferences
import com.rmusic.android.query
import com.rmusic.android.service.BitmapProvider
import com.rmusic.android.service.MusicDownloadService
import com.rmusic.android.service.PlayableFormatNotFoundException
import com.rmusic.android.service.ServiceNotifications
import com.rmusic.android.service.VideoIdMismatchException
import com.rmusic.android.service.UnplayableException
import com.rmusic.android.service.LoginRequiredException
import com.rmusic.android.service.RestrictedVideoException
import com.rmusic.android.transaction
import com.rmusic.android.utils.ActionReceiver
import com.rmusic.android.utils.ConditionalCacheDataSourceFactory
import com.rmusic.android.utils.GlyphInterface
import com.rmusic.android.utils.InvincibleService
import com.rmusic.android.utils.TimerJob
import com.rmusic.android.utils.YouTubeRadio
import com.rmusic.android.utils.activityPendingIntent
import com.rmusic.android.utils.asDataSource
import com.rmusic.android.utils.broadcastPendingIntent
import com.rmusic.android.utils.defaultDataSource
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
import com.rmusic.providers.innertube.InvalidHttpCodeException
import com.rmusic.providers.innertube.models.NavigationEndpoint
import com.rmusic.providers.innertube.models.bodies.PlayerBody
import com.rmusic.providers.innertube.models.bodies.SearchBody
import com.rmusic.providers.innertube.requests.searchPage
import com.rmusic.providers.innertube.utils.from
import com.rmusic.providers.sponsorblock.SponsorBlock
import com.rmusic.providers.sponsorblock.models.Action
import com.rmusic.providers.sponsorblock.models.Category
import com.rmusic.providers.sponsorblock.requests.segments
import io.ktor.client.plugins.ClientRequestException
import java.io.File
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
import kotlinx.datetime.Clock
import java.io.IOException
import kotlin.math.roundToInt
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import android.os.Binder as AndroidBinder

const val LOCAL_KEY_PREFIX = "local:"
private const val TAG = "PlayerService"

@get:OptIn(UnstableApi::class)
val DataSpec.isLocal get() = key?.startsWith(LOCAL_KEY_PREFIX) == true

val MediaItem.isLocal get() = mediaId.startsWith(LOCAL_KEY_PREFIX)
val Song.isLocal get() = id.startsWith(LOCAL_KEY_PREFIX)

private const val LIKE_ACTION = "LIKE"
private const val LOOP_ACTION = "LOOP"

@kotlin.OptIn(ExperimentalCoroutinesApi::class)
@Suppress("LargeClass", "TooManyFunctions") // intended in this class: it is a service
@OptIn(UnstableApi::class)
class PlayerService : InvincibleService(), Player.Listener, PlaybackStatsListener.Callback {
    private lateinit var mediaSession: MediaSession
    private lateinit var cache: Cache
    private lateinit var player: ExoPlayer

    /**
     * Sistema de caché temporal inteligente
     * Solo mantiene en caché la canción actual y la siguiente
     */
    private class TemporalSmartCache {
        private var currentSongId: String? = null
        private var nextSongId: String? = null
        private val cachedItems = mutableSetOf<String>()

        fun updateCurrentAndNext(current: String?, next: String?, cache: Cache) {
            // Limpiar items que ya no son relevantes
            val itemsToRemove = cachedItems.filter { 
                it != current && it != next && !it.startsWith(LOCAL_KEY_PREFIX)
            }
            itemsToRemove.forEach { songId ->
                try {
                    cache.removeResource(songId)
                    cachedItems.remove(songId)
                } catch (e: Exception) {
                    // Ignorar errores de limpieza
                }
            }

            // Actualizar referencias
            currentSongId = current
            nextSongId = next
            
            // Marcar como cacheados los items actuales
            current?.let { cachedItems.add(it) }
            next?.let { cachedItems.add(it) }
        }

        fun clearAll(cache: Cache) {
            cachedItems.filter { !it.startsWith(LOCAL_KEY_PREFIX) }.forEach { songId ->
                try {
                    cache.removeResource(songId)
                } catch (e: Exception) {
                    // Ignorar errores de limpieza
                }
            }
            cachedItems.clear()
            currentSongId = null
            nextSongId = null
        }

        fun isRelevant(songId: String): Boolean {
            return songId == currentSongId || songId == nextSongId || songId.startsWith(LOCAL_KEY_PREFIX)
        }
    }

    private val temporalCache = TemporalSmartCache()

    private val defaultActions =
        PlaybackState.ACTION_PLAY or
            PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_PLAY_PAUSE or
            PlaybackState.ACTION_STOP or
            PlaybackState.ACTION_SKIP_TO_PREVIOUS or
            PlaybackState.ACTION_SKIP_TO_NEXT or
            PlaybackState.ACTION_SKIP_TO_QUEUE_ITEM or
            PlaybackState.ACTION_SEEK_TO or
            PlaybackState.ACTION_REWIND or
            PlaybackState.ACTION_PLAY_FROM_SEARCH

    private val stateBuilder
        get() = PlaybackState.Builder().setActions(
            defaultActions.let {
                if (isAtLeastAndroid12) it or PlaybackState.ACTION_SET_PLAYBACK_SPEED else it
            }
        ).addCustomAction(
            PlaybackState.CustomAction.Builder(
                /* action = */ LIKE_ACTION,
                /* name   = */ getString(R.string.like),
                /* icon   = */
                if (isLikedState.value) R.drawable.heart else R.drawable.heart_outline
            ).build()
        ).addCustomAction(
            PlaybackState.CustomAction.Builder(
                /* action = */ LOOP_ACTION,
                /* name   = */ getString(R.string.queue_loop),
                /* icon   = */
                if (PlayerPreferences.trackLoopEnabled) R.drawable.repeat_on else R.drawable.repeat
            ).build()
        )

    private val playbackStateMutex = Mutex()
    private val metadataBuilder = MediaMetadata.Builder()

    private var timerJob: TimerJob? by mutableStateOf(null)
    private var radio: YouTubeRadio? = null

    private lateinit var bitmapProvider: BitmapProvider

    private val coroutineScope = CoroutineScope(Dispatchers.IO + Job())
    private var preferenceUpdaterJob: Job? = null
    private var volumeNormalizationJob: Job? = null
    private var sponsorBlockJob: Job? = null

    override var isInvincibilityEnabled by mutableStateOf(false)

    private var audioManager: AudioManager? = null
    private var audioDeviceCallback: AudioDeviceCallback? = null

    private var loudnessEnhancer: LoudnessEnhancer? = null
    private var bassBoost: BassBoost? = null
    private var reverb: PresetReverb? = null

    // Store detailed error information for UI access
    @Volatile
    private var lastDetailedError: String? = null

    private val binder = Binder()

    private var isNotificationStarted = false
    override val notificationId get() = ServiceNotifications.default.notificationId!!
    private val notificationActionReceiver = NotificationActionReceiver()

    private val mediaItemState = MutableStateFlow<MediaItem?>(null)
    private val isLikedState = mediaItemState
        .flatMapMerge { item ->
            item?.mediaId?.let {
                Database
                    .likedAt(it)
                    .distinctUntilChanged()
                    .cancellable()
            } ?: flowOf(null)
        }
        .map { it != null }
        .onEach {
            updateNotification()
        }
        .stateIn(
            scope = coroutineScope,
            started = SharingStarted.Eagerly,
            initialValue = false
        )

    // Track songs that have reached 50% playback for auto-download
    private val autoDownloadedSongs = mutableSetOf<String>()

    // Sistema de reproducción inteligente para manejar errores de source
    private var retryCount = 0
    private var maxRetries = 2
    private var retryDelayMs = 1000L // Reducido de 2000ms a 1000ms para reintentos más rápidos
    private var currentRetryJob: Job? = null
    private val retryAttempts = mutableMapOf<String, Int>()

    private val glyphInterface by lazy { GlyphInterface(applicationContext) }

    private var poiTimestamp: Long? by mutableStateOf(null)

    override fun onBind(intent: Intent?): AndroidBinder {
        super.onBind(intent)
        return binder
    }

    @Suppress("CyclomaticComplexMethod")
    override fun onCreate() {
        super.onCreate()

        glyphInterface.tryInit()
        notificationActionReceiver.register()

        bitmapProvider = BitmapProvider(
            getBitmapSize = {
                (512 * resources.displayMetrics.density)
                    .roundToInt()
                    .coerceAtMost(AppearancePreferences.maxThumbnailSize)
            },
            getColor = { isSystemInDarkMode ->
                if (isSystemInDarkMode) Color.BLACK else Color.WHITE
            }
        )

        cache = createCache(this)
        player = ExoPlayer.Builder(this, createRendersFactory(), createMediaSourceFactory())
            .setHandleAudioBecomingNoisy(true)
            .setWakeMode(C.WAKE_MODE_LOCAL)
            .setAudioAttributes(
                /* audioAttributes = */ AudioAttributes.Builder()
                    .setUsage(C.USAGE_MEDIA)
                    .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                    .build(),
                /* handleAudioFocus = */ PlayerPreferences.handleAudioFocus
            )
            .setUsePlatformDiagnostics(false)
            .build()
            .apply {
                skipSilenceEnabled = PlayerPreferences.skipSilence
                addListener(this@PlayerService)
                addAnalyticsListener(
                    PlaybackStatsListener(
                        /* keepHistory = */ false,
                        /* callback = */ this@PlayerService
                    )
                )
            }

        updateRepeatMode()
        maybeRestorePlayerQueue()

        mediaSession = MediaSession(baseContext, TAG).apply {
            setCallback(SessionCallback())
            setPlaybackState(stateBuilder.build())
            setSessionActivity(activityPendingIntent<MainActivity>())
            isActive = true
        }

        coroutineScope.launch {
            var first = true
            combine(mediaItemState, isLikedState) { mediaItem, _ ->
                // work around NPE in other processes
                if (first) {
                    first = false
                    return@combine
                }

                if (mediaItem == null) return@combine
                withContext(Dispatchers.Main) {
                    updatePlaybackState()
                    updateNotification()
                }
            }.collect()
        }

        maybeResumePlaybackWhenDeviceConnected()

        preferenceUpdaterJob = coroutineScope.launch {
            fun <T : Any> subscribe(
                prop: SharedPreferencesProperty<T>,
                callback: (T) -> Unit
            ) = launch { prop.stateFlow.collectLatest { handler.post { callback(it) } } }

            subscribe(AppearancePreferences.isShowingThumbnailInLockscreenProperty) {
                maybeShowSongCoverInLockScreen()
            }

            subscribe(PlayerPreferences.bassBoostLevelProperty) { maybeBassBoost() }
            subscribe(PlayerPreferences.bassBoostProperty) { maybeBassBoost() }
            subscribe(PlayerPreferences.reverbProperty) { maybeReverb() }
            subscribe(PlayerPreferences.isInvincibilityEnabledProperty) {
                this@PlayerService.isInvincibilityEnabled = it
            }
            subscribe(PlayerPreferences.pitchProperty) {
                player.setPlaybackPitch(it.coerceAtLeast(0.01f))
            }
            subscribe(PlayerPreferences.queueLoopEnabledProperty) { updateRepeatMode() }
            subscribe(PlayerPreferences.resumePlaybackWhenDeviceConnectedProperty) {
                maybeResumePlaybackWhenDeviceConnected()
            }
            subscribe(PlayerPreferences.skipSilenceProperty) { player.skipSilenceEnabled = it }
            subscribe(PlayerPreferences.speedProperty) {
                player.setPlaybackSpeed(it.coerceAtLeast(0.01f))
            }
            subscribe(PlayerPreferences.trackLoopEnabledProperty) {
                updateRepeatMode()
                updateNotification()
            }
            subscribe(PlayerPreferences.volumeNormalizationBaseGainProperty) { maybeNormalizeVolume() }
            subscribe(PlayerPreferences.volumeNormalizationProperty) { maybeNormalizeVolume() }
            subscribe(PlayerPreferences.sponsorBlockEnabledProperty) { maybeSponsorBlock() }
            subscribe(PlayerPreferences.autoDownloadAtHalfProperty) { 
                // Reset tracked songs when preference changes
                if (!it) autoDownloadedSongs.clear()
            }

            // Auto-download monitoring - check progress every second when enabled
            launch {
                while (isActive) {
                    // Only check auto-download if the preference is enabled
                    if (PlayerPreferences.autoDownloadAtHalf) {
                        try {
                            maybeAutoDownload()
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in auto-download check", e)
                        }
                        // Check every second when enabled
                        delay(1000)
                    } else {
                        // Check every 30 seconds when disabled to save resources
                        delay(30000)
                    }
                }
            }

            launch {
                val audioManager = getSystemService<AudioManager>()
                val stream = AudioManager.STREAM_MUSIC

                val min = when {
                    audioManager == null -> 0
                    isAtLeastAndroid9 -> audioManager.getStreamMinVolume(stream)

                    else -> 0
                }

                streamVolumeFlow(stream).collectLatest {
                    if (PlayerPreferences.stopOnMinimumVolume && it == min) handler.post(player::pause)
                }
            }
        }
    }

    private fun updateRepeatMode() {
        player.repeatMode = when {
            PlayerPreferences.trackLoopEnabled -> Player.REPEAT_MODE_ONE
            PlayerPreferences.queueLoopEnabled -> Player.REPEAT_MODE_ALL
            else -> Player.REPEAT_MODE_OFF
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        if (!player.shouldBePlaying || PlayerPreferences.stopWhenClosed)
            broadcastPendingIntent<NotificationDismissReceiver>().send()
        super.onTaskRemoved(rootIntent)
    }

    override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) =
        maybeSavePlayerQueue()

    override fun onDestroy() {
        runCatching {
            maybeSavePlayerQueue()

            // Limpiar sistema de reproducción inteligente
            currentRetryJob?.cancel()
            retryAttempts.clear()

            // Limpiar caché temporal al cerrar
            temporalCache.clearAll(cache)

            player.removeListener(this)
            player.stop()
            player.release()

            unregisterReceiver(notificationActionReceiver)

            mediaSession.isActive = false
            mediaSession.release()
            cache.release()

            loudnessEnhancer?.release()
            preferenceUpdaterJob?.cancel()

            coroutineScope.cancel()
            glyphInterface.close()
        }

        super.onDestroy()
    }

    override fun shouldBeInvincible() = !player.shouldBePlaying

    override fun onConfigurationChanged(newConfig: Configuration) {
        handler.post {
            if (!bitmapProvider.setDefaultBitmap() || player.currentMediaItem == null) return@post
            updateNotification()
        }

        super.onConfigurationChanged(newConfig)
    }

    override fun onPlaybackStatsReady(
        eventTime: AnalyticsListener.EventTime,
        playbackStats: PlaybackStats
    ) {
        val totalPlayTimeMs = playbackStats.totalPlayTimeMs
        if (totalPlayTimeMs < 5000) return

        val mediaItem = eventTime.timeline[eventTime.windowIndex].mediaItem

        if (!DataPreferences.pausePlaytime) query {
            runCatching {
                Database.incrementTotalPlayTimeMs(mediaItem.mediaId, totalPlayTimeMs)
            }
        }

        if (!DataPreferences.pauseHistory) query {
            runCatching {
                Database.insert(
                    Event(
                        songId = mediaItem.mediaId,
                        timestamp = System.currentTimeMillis(),
                        playTime = totalPlayTimeMs
                    )
                )
            }
        }
    }

    override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
        if (
            AppearancePreferences.hideExplicit &&
            mediaItem?.mediaMetadata?.extras?.songBundle?.explicit == true
        ) {
            player.forceSeekToNext()
            return
        }

        mediaItemState.update { mediaItem }

        // Reset auto-download tracking for previous song when transitioning
        if (reason == Player.MEDIA_ITEM_TRANSITION_REASON_AUTO || 
            reason == Player.MEDIA_ITEM_TRANSITION_REASON_SEEK) {
            // Keep only recent songs to avoid memory leaks (last 10 songs)
            val currentId = mediaItem?.mediaId
            if (autoDownloadedSongs.size > 10) {
                // Clear older entries, keeping some recent ones
                val recentSongs = autoDownloadedSongs.toList().takeLast(5).toMutableSet()
                autoDownloadedSongs.clear()
                autoDownloadedSongs.addAll(recentSongs)
            }

            // Limpiar contadores de reintento para canciones exitosas
            // Solo mantener los últimos 3 intentos para evitar acumulación de memoria
            currentId?.let { 
                retryAttempts.remove(it)
                if (retryAttempts.size > 3) {
                    val recentRetries = retryAttempts.toList().takeLast(3).toMap()
                    retryAttempts.clear()
                    retryAttempts.putAll(recentRetries)
                }
            }
            
            // Cancelar trabajos de reintento activos al cambiar de canción
            currentRetryJob?.cancel()
        }

        // Actualizar caché temporal inteligente
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
        // Actualizar caché temporal cuando cambie la playlist
        updateTemporalCache()
    }

    override fun onPlayerError(error: PlaybackException) {
        val mediaItem = player.currentMediaItem
        val mediaId = mediaItem?.mediaId ?: ""
        val attempts = retryAttempts.getOrDefault(mediaId, 0)
        
        // Crear mensaje de error detallado para debug
        val detailedError = buildString {
            append("PlaybackException: ")
            append("errorCode=${error.errorCode}, ")
            append("message='${error.message}', ")
            append("cause=${error.cause?.javaClass?.simpleName}:'${error.cause?.message}', ")
            
            // Buscar causas específicas
            error.findCause<InvalidResponseCodeException>()?.let { httpError ->
                append("HTTP_${httpError.responseCode}, ")
            }
            error.findCause<java.net.UnknownHostException>()?.let { 
                append("DNS_FAILURE, ")
            }
            error.findCause<java.net.SocketTimeoutException>()?.let { 
                append("TIMEOUT, ")
            }
            error.findCause<java.net.ConnectException>()?.let { 
                append("CONNECTION_FAILED, ")
            }
            error.findCause<javax.net.ssl.SSLException>()?.let { 
                append("SSL_ERROR, ")
            }
            
            append("stackTrace=${error.stackTraceToString().take(200)}")
        }
        
        // Log completo del error
        Log.e(TAG, "PlaybackError (attempt ${attempts + 1}/$maxRetries): $detailedError", error)
        
        // Mostrar error raw en debug
        if (BuildConfig.DEBUG) {
            showDebugNotification("RAW ERROR: $detailedError")
        }
        
        // Intentar recuperación inteligente antes de mostrar error o saltar
        if (shouldRetryPlayback(error)) {
            showDebugNotification("Attempting retry for error: ${error.errorCode}")
            handleIntelligentRetry(error)
            return
        }

        // Mostrar mensaje de error detallado
        val userFriendlyError = if (BuildConfig.DEBUG) {
            // En debug, mostrar más detalles
            "Code:${error.errorCode} ${error.message ?: error::class.simpleName}"
        } else {
            // En release, mensaje más amigable
            error.message ?: error::class.simpleName ?: "Unknown"
        }
        
        if (attempts > 0) {
            toast(getString(R.string.playback_error, "$userFriendlyError (reintentos agotados: $attempts/$maxRetries)"))
        } else {
            toast(getString(R.string.playback_error, userFriendlyError))
        }

        super.onPlayerError(error)

        // Caso especial para error 416 (Range Not Satisfiable)
        if (error.findCause<InvalidResponseCodeException>()?.responseCode == 416) {
            showDebugNotification("Handling 416 error with pause/prepare/play")
            player.pause()
            player.prepare()
            player.play()
            return
        }

        if (!PlayerPreferences.skipOnError || !player.hasNextMediaItem()) return

        val prev = player.currentMediaItem ?: return
        player.seekToNextMediaItem()

        ServiceNotifications.autoSkip.sendNotification(this) {
            this
                .setSmallIcon(R.drawable.app_icon)
                .setCategory(NotificationCompat.CATEGORY_ERROR)
                .setOnlyAlertOnce(false)
                .setContentIntent(activityPendingIntent<MainActivity>())
                .setContentText(
                    prev.mediaMetadata.title?.let {
                        getString(R.string.skip_on_error_notification, it)
                    } ?: getString(R.string.skip_on_error_notification_unknown_song)
                )
                .setContentTitle(getString(R.string.skip_on_error))
        }
    }

    /**
     * Actualiza el caché temporal para mantener solo la canción actual y la siguiente
     */
    private fun updateTemporalCache() {
        try {
            val currentIndex = player.currentMediaItemIndex
            val currentItem = player.currentMediaItem
            val nextItem = if (currentIndex + 1 < player.mediaItemCount) {
                player.getMediaItemAt(currentIndex + 1)
            } else null

            temporalCache.updateCurrentAndNext(
                current = currentItem?.mediaId,
                next = nextItem?.mediaId,
                cache = cache
            )
        } catch (e: Exception) {
            // Ignorar errores del caché temporal
            Log.w(TAG, "Error updating temporal cache", e)
        }
    }

    /**
     * Verifica si hay conexión a internet disponible
     */
    private fun isNetworkConnected(): Boolean {
        return try {
            val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = connectivityManager.activeNetwork ?: return false
            val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
            
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ||
            networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
        } catch (e: Exception) {
            Log.w(TAG, "Error checking network connectivity", e)
            false
        }
    }

    /**
     * Determina si el error requiere un reintento inteligente
     */
    private fun shouldRetryPlayback(error: PlaybackException): Boolean {
        val mediaItem = player.currentMediaItem ?: return false
        val mediaId = mediaItem.mediaId
        
        // No reintentar archivos locales
        if (mediaId.startsWith(LOCAL_KEY_PREFIX)) return false
        
        // Obtener número de intentos para esta canción
        val attempts = retryAttempts.getOrDefault(mediaId, 0)
        if (attempts >= maxRetries) return false
        
        // Log detallado para debug
        if (BuildConfig.DEBUG) {
            val shouldRetry = when {
                // Errores de red/conectividad - siempre reintentar
                error.findCause<java.net.UnknownHostException>() != null -> "DNS_FAILURE"
                error.findCause<java.net.SocketTimeoutException>() != null -> "SOCKET_TIMEOUT"
                error.findCause<java.net.ConnectException>() != null -> "CONNECTION_FAILED"
                error.findCause<javax.net.ssl.SSLException>() != null -> "SSL_ERROR"
                
                // Errores HTTP que pueden ser temporales
                error.findCause<InvalidResponseCodeException>()?.let { httpError ->
                    when (httpError.responseCode) {
                        500, 502, 503, 504 -> "HTTP_SERVER_ERROR_${httpError.responseCode}"
                        429 -> "HTTP_RATE_LIMIT"
                        403 -> "HTTP_FORBIDDEN"
                        404 -> "HTTP_NOT_FOUND"
                        else -> null
                    }
                } != null -> "HTTP_ERROR"
                
                // Errores de ExoPlayer que pueden ser temporales
                error.errorCode == PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED -> "EXOPLAYER_NETWORK_FAILED"
                error.errorCode == PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT -> "EXOPLAYER_NETWORK_TIMEOUT"
                error.errorCode == PlaybackException.ERROR_CODE_IO_READ_POSITION_OUT_OF_RANGE -> "EXOPLAYER_READ_OUT_OF_RANGE"
                error.errorCode == PlaybackException.ERROR_CODE_IO_UNSPECIFIED -> "EXOPLAYER_IO_UNSPECIFIED"
                error.errorCode == PlaybackException.ERROR_CODE_IO_INVALID_HTTP_CONTENT_TYPE -> "EXOPLAYER_INVALID_CONTENT_TYPE"
                error.errorCode == PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS -> "EXOPLAYER_BAD_HTTP_STATUS"
                error.errorCode == PlaybackException.ERROR_CODE_PARSING_CONTAINER_MALFORMED -> "EXOPLAYER_CONTAINER_MALFORMED"
                error.errorCode == PlaybackException.ERROR_CODE_PARSING_MANIFEST_MALFORMED -> "EXOPLAYER_MANIFEST_MALFORMED"
                
                // Errores que contienen palabras clave relacionadas con streaming
                error.message?.contains("innertube", ignoreCase = true) == true -> "INNERTUBE_ERROR"
                error.message?.contains("youtube", ignoreCase = true) == true -> "YOUTUBE_ERROR"
                error.message?.contains("source", ignoreCase = true) == true -> "SOURCE_ERROR"
                error.message?.contains("stream", ignoreCase = true) == true -> "STREAM_ERROR"
                error.message?.contains("network", ignoreCase = true) == true -> "NETWORK_ERROR"
                error.message?.contains("connection", ignoreCase = true) == true -> "CONNECTION_ERROR"
                error.message?.contains("timeout", ignoreCase = true) == true -> "TIMEOUT_ERROR"
                
                else -> null
            }
            
            if (shouldRetry != null) {
                showDebugNotification("RETRY REASON: $shouldRetry (attempt ${attempts + 1}/$maxRetries)")
            } else {
                showDebugNotification("NO RETRY: Error not retryable")
            }
        }
        
        // Verificar tipos de error que pueden beneficiarse de reintento
        return when {
            // Errores de red/conectividad - siempre reintentar
            error.findCause<java.net.UnknownHostException>() != null -> true
            error.findCause<java.net.SocketTimeoutException>() != null -> true
            error.findCause<java.net.ConnectException>() != null -> true
            error.findCause<javax.net.ssl.SSLException>() != null -> true
            
            // Errores HTTP que pueden ser temporales
            error.findCause<InvalidResponseCodeException>()?.let { httpError ->
                httpError.responseCode in listOf(500, 502, 503, 504, 429, 403, 404, 410, 412)
            } == true -> true
            
            // Errores de source que pueden ser temporales - más agresivo para Innertube
            error.errorCode == PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED -> true
            error.errorCode == PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT -> true
            error.errorCode == PlaybackException.ERROR_CODE_IO_READ_POSITION_OUT_OF_RANGE -> true
            error.errorCode == PlaybackException.ERROR_CODE_IO_UNSPECIFIED -> true
            error.errorCode == PlaybackException.ERROR_CODE_IO_INVALID_HTTP_CONTENT_TYPE -> true
            error.errorCode == PlaybackException.ERROR_CODE_IO_BAD_HTTP_STATUS -> true
            
            // Errores de fuente/source - comunes con Innertube
            error.errorCode == PlaybackException.ERROR_CODE_PARSING_CONTAINER_MALFORMED -> true
            error.errorCode == PlaybackException.ERROR_CODE_PARSING_MANIFEST_MALFORMED -> true
            
            // Cualquier error que contenga palabras clave de Innertube/YouTube
            error.message?.contains("innertube", ignoreCase = true) == true -> true
            error.message?.contains("youtube", ignoreCase = true) == true -> true
            error.message?.contains("source", ignoreCase = true) == true -> true
            error.message?.contains("stream", ignoreCase = true) == true -> true
            error.message?.contains("network", ignoreCase = true) == true -> true
            error.message?.contains("connection", ignoreCase = true) == true -> true
            error.message?.contains("timeout", ignoreCase = true) == true -> true
            
            else -> false
        }
    }

    /**
     * Maneja el reintento inteligente de reproducción
     */
    private fun handleIntelligentRetry(error: PlaybackException) {
        val mediaItem = player.currentMediaItem ?: return
        val mediaId = mediaItem.mediaId
        
        // Cancelar trabajo de reintento anterior si existe
        currentRetryJob?.cancel()
        
        // Incrementar contador de intentos
        val attempts = retryAttempts.getOrDefault(mediaId, 0) + 1
        retryAttempts[mediaId] = attempts
        
        val title = mediaItem.mediaMetadata.title?.toString() ?: "Unknown"
        
        showDebugNotification("Reintentando reproducción ($attempts/$maxRetries): $title")
        
        // Verificar conexión antes de reintentar
        if (!isNetworkConnected()) {
            showDebugNotification("Sin conexión a internet, esperando...")
            // Esperar más tiempo si no hay red
            scheduleRetryWithNetworkCheck(mediaItem, attempts, retryDelayMs * 3)
            return
        }
        
        currentRetryJob = coroutineScope.launch {
            try {
                // Calcular delay - primer intento inmediato, segundo con delay mínimo
                val delay = if (attempts == 1) {
                    // Primer reintento inmediato para errores de Innertube/source
                    200L // Solo una pequeña pausa para estabilizar
                } else {
                    // Segundo reintento con delay progresivo
                    retryDelayMs * attempts
                }
                
                if (delay > 200L) {
                    showDebugNotification("Esperando ${delay}ms antes del reintento...")
                }
                delay(delay)
                
                // Verificar que el contexto sigue activo y que seguimos en la misma canción
                if (!isActive || player.currentMediaItem?.mediaId != mediaId) {
                    showDebugNotification("Contexto cambió, cancelando reintento")
                    return@launch
                }
                
                // Verificar conexión nuevamente antes del reintento
                if (!isNetworkConnected()) {
                    showDebugNotification("Sin conexión, reintentando en 10s...")
                    delay(10000)
                    if (!isActive || player.currentMediaItem?.mediaId != mediaId) return@launch
                }
                
                withContext(Dispatchers.Main) {
                    showDebugNotification("Ejecutando reintento inmediato $attempts/$maxRetries...")
                    
                    // Intentar recuperar la reproducción
                    try {
                        // Para el primer reintento, usar método más directo
                        if (attempts == 1) {
                            // Reintento inmediato - solo pausar y reproducir
                            val wasPlaying = player.isPlaying
                            player.pause()
                            
                            // Pausa mínima para resetear el estado
                            delay(100)
                            
                            if (player.playWhenReady || wasPlaying) {
                                player.play()
                            }
                        } else {
                            // Segundo reintento - método más profundo
                            player.pause()
                            player.prepare()
                            
                            // Pequeña pausa para permitir que se prepare
                            delay(500)
                            
                            if (player.playWhenReady) {
                                player.play()
                            }
                        }
                        
                        showDebugNotification("Reintento exitoso para: $title")
                        
                        // Limpiar contador de intentos si fue exitoso
                        // (se limpiará en onMediaItemTransition si la reproducción continúa)
                        
                    } catch (e: Exception) {
                        showDebugNotification("Error en reintento: ${e.message}")
                        
                        // Si alcanzamos el máximo de intentos, proceder con el manejo normal de errores
                        if (attempts >= maxRetries) {
                            showDebugNotification("Máximo de reintentos alcanzado para: $title")
                            handleFinalError(error, mediaItem)
                        }
                    }
                }
                
            } catch (e: Exception) {
                if (e !is kotlinx.coroutines.CancellationException) {
                    Log.e(TAG, "Error in retry job", e)
                    showDebugNotification("Error en trabajo de reintento: ${e.message}")
                }
            }
        }
    }

    /**
     * Programa un reintento con verificación de red periódica
     */
    private fun scheduleRetryWithNetworkCheck(mediaItem: MediaItem, attempts: Int, delayMs: Long) {
        currentRetryJob = coroutineScope.launch {
            try {
                val startTime = System.currentTimeMillis()
                val maxWaitTime = delayMs * 2 // Máximo tiempo de espera
                
                // Esperar hasta que haya conexión o se agote el tiempo
                while (!isNetworkConnected() && 
                       (System.currentTimeMillis() - startTime) < maxWaitTime &&
                       isActive &&
                       player.currentMediaItem?.mediaId == mediaItem.mediaId) {
                    
                    showDebugNotification("Esperando conexión a internet...")
                    delay(2000) // Verificar cada 2 segundos
                }
                
                if (!isActive || player.currentMediaItem?.mediaId != mediaItem.mediaId) {
                    return@launch
                }
                
                if (isNetworkConnected()) {
                    showDebugNotification("Conexión restaurada, reintentando...")
                    // Continuar con el reintento normal
                    handleIntelligentRetry(PlaybackException("Network reconnected", null, PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_FAILED))
                } else {
                    showDebugNotification("Sin conexión después de esperar, fallando...")
                    withContext(Dispatchers.Main) {
                        handleFinalError(
                            PlaybackException("Network timeout", null, PlaybackException.ERROR_CODE_IO_NETWORK_CONNECTION_TIMEOUT),
                            mediaItem
                        )
                    }
                }
                
            } catch (e: Exception) {
                if (e !is kotlinx.coroutines.CancellationException) {
                    Log.e(TAG, "Error in network check retry", e)
                }
            }
        }
    }

    /**
     * Maneja el error final cuando se agotan los reintentos
     */
    private fun handleFinalError(error: PlaybackException, mediaItem: MediaItem) {
        val detailed = error.message ?: error::class.simpleName ?: "Unknown"
        val title = mediaItem.mediaMetadata.title?.toString() ?: "Unknown"
        
        showDebugNotification("Error final después de reintentos: $title")
        toast(getString(R.string.playback_error, "$detailed (reintentos agotados)"))
        
        // Limpiar contador de intentos
        retryAttempts.remove(mediaItem.mediaId)
        
        // Proceder con el manejo normal de errores
        if (PlayerPreferences.skipOnError && player.hasNextMediaItem()) {
            player.seekToNextMediaItem()
            
            ServiceNotifications.autoSkip.sendNotification(this) {
                this
                    .setSmallIcon(R.drawable.app_icon)
                    .setCategory(NotificationCompat.CATEGORY_ERROR)
                    .setOnlyAlertOnce(false)
                    .setContentIntent(activityPendingIntent<MainActivity>())
                    .setContentText(
                        getString(R.string.skip_on_error_notification, title)
                    )
                    .setContentTitle(getString(R.string.skip_on_error))
            }
        }
    }

    private fun updateMediaSessionQueue(timeline: Timeline) {
        val builder = MediaDescription.Builder()

        val currentMediaItemIndex = player.currentMediaItemIndex
        val lastIndex = timeline.windowCount - 1
        var startIndex = currentMediaItemIndex - 7
        var endIndex = currentMediaItemIndex + 7

        if (startIndex < 0) endIndex -= startIndex

        if (endIndex > lastIndex) {
            startIndex -= (endIndex - lastIndex)
            endIndex = lastIndex
        }

        startIndex = startIndex.coerceAtLeast(0)

        mediaSession.setQueue(
            List(endIndex - startIndex + 1) { index ->
                val mediaItem = timeline.getWindow(index + startIndex, Timeline.Window()).mediaItem
                MediaSession.QueueItem(
                    builder
                        .setMediaId(mediaItem.mediaId)
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
        if (player.mediaItemCount - player.currentMediaItemIndex > 3) return

        radio?.let { radio ->
            coroutineScope.launch(Dispatchers.Main) {
                player.addMediaItems(radio.process())
            }
        }
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
                        QueuedMediaItem(
                            mediaItem = mediaItem,
                            position = if (index == mediaItemIndex) mediaItemPosition else null
                        )
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

            val index = queue
                .indexOfFirst { it.position != null }
                .coerceAtLeast(0)

            handler.post {
                runCatching {
                    player.setMediaItems(
                        /* mediaItems = */ queue.map { item ->
                            item.mediaItem.buildUpon()
                                .setUri(item.mediaItem.mediaId)
                                .setCustomCacheKey(item.mediaItem.mediaId)
                                .build()
                                .apply {
                                    mediaMetadata.extras?.songBundle?.apply {
                                        isFromPersistentQueue = true
                                    }
                                }
                        },
                        /* startIndex = */ index,
                        /* startPositionMs = */ queue[index].position ?: C.TIME_UNSET
                    )
                    player.prepare()

                    isNotificationStarted = true
                    startForegroundService(this@PlayerService, intent<PlayerService>())
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
            volumeNormalizationJob?.invokeOnCompletion { volumeNormalizationJob = null }
            player.volume = 1f
            return
        }

        runCatching {
            if (loudnessEnhancer == null) loudnessEnhancer = LoudnessEnhancer(player.audioSessionId)
        }.onFailure { return }

        val songId = player.currentMediaItem?.mediaId ?: return
        volumeNormalizationJob?.cancel()
        volumeNormalizationJob = coroutineScope.launch {
            runCatching {
                fun Float?.toMb() = ((this ?: 0f) * 100).toInt()

                Database.loudnessDb(songId).cancellable().collectLatest { loudness ->
                    val loudnessMb = loudness.toMb().let {
                        if (it !in -2000..2000) {
                            withContext(Dispatchers.Main) {
                                toast(
                                    getString(
                                        R.string.loudness_normalization_extreme,
                                        getString(R.string.format_db, (it / 100f).toString())
                                    )
                                )
                            }

                            0
                        } else it
                    }

                    Database.loudnessBoost(songId).cancellable().collectLatest { boost ->
                        withContext(Dispatchers.Main) {
                            loudnessEnhancer?.setTargetGain(
                                PlayerPreferences.volumeNormalizationBaseGain.toMb() + boost.toMb() - loudnessMb
                            )
                            loudnessEnhancer?.enabled = true
                        }
                    }
                }
            }
        }
    }

    @Suppress("CyclomaticComplexMethod") // TODO: evaluate CyclomaticComplexMethod threshold
    private fun maybeSponsorBlock() {
        poiTimestamp = null

        if (!PlayerPreferences.sponsorBlockEnabled) {
            sponsorBlockJob?.cancel()
            sponsorBlockJob?.invokeOnCompletion { sponsorBlockJob = null }
            return
        }

        sponsorBlockJob?.cancel()
        sponsorBlockJob = coroutineScope.launch {
            mediaItemState.onStart { emit(mediaItemState.value) }.collectLatest { mediaItem ->
                poiTimestamp = null
                val videoId = mediaItem?.mediaId
                    ?.removePrefix("https://youtube.com/watch?v=")
                    ?.takeIf { it.isNotBlank() } ?: return@collectLatest

                SponsorBlock
                    .segments(videoId)
                    ?.onSuccess { segments ->
                        poiTimestamp =
                            segments.find { it.category == Category.PoiHighlight }?.start?.inWholeMilliseconds
                    }
                    ?.map { segments ->
                        segments
                            .sortedBy { it.start.inWholeMilliseconds }
                            .filter { it.action == Action.Skip }
                    }
                    ?.mapCatching { segments ->
                        suspend fun posMillis() =
                            withContext(Dispatchers.Main) { player.currentPosition }

                        suspend fun speed() =
                            withContext(Dispatchers.Main) { player.playbackParameters.speed }

                        suspend fun seek(millis: Long) =
                            withContext(Dispatchers.Main) { player.seekTo(millis) }

                        val ctx = currentCoroutineContext()
                        val lastSegmentEnd =
                            segments.lastOrNull()?.end?.inWholeMilliseconds ?: return@mapCatching

                        @Suppress("LoopWithTooManyJumpStatements")
                        do {
                            if (lastSegmentEnd < posMillis()) {
                                yield()
                                continue
                            }

                            val nextSegment =
                                segments.firstOrNull { posMillis() < it.end.inWholeMilliseconds }
                                    ?: continue

                            // Wait for next segment
                            if (nextSegment.start.inWholeMilliseconds > posMillis()) {
                                val timeNextSegment = nextSegment.start.inWholeMilliseconds - posMillis()
                                val speed = speed().toDouble()
                                delay((timeNextSegment / speed).milliseconds)
                            }

                            if (posMillis().milliseconds !in nextSegment.start..nextSegment.end) {
                                // Player is not in the segment for some reason, maybe the user seeked in the meantime
                                yield()
                                continue
                            }

                            seek(nextSegment.end.inWholeMilliseconds)
                        } while (ctx.isActive)
                    }?.onFailure {
                        it.printStackTrace()
                    }
            }
        }
    }

    private fun maybeBassBoost() {
        if (!PlayerPreferences.bassBoost) {
            runCatching {
                bassBoost?.enabled = false
                bassBoost?.release()
            }
            bassBoost = null
            maybeNormalizeVolume()
            return
        }

        runCatching {
            if (bassBoost == null) bassBoost = BassBoost(0, player.audioSessionId)
            bassBoost?.setStrength(PlayerPreferences.bassBoostLevel.toShort())
            bassBoost?.enabled = true
        }.onFailure {
            toast(getString(R.string.error_bassboost_init))
        }
    }

    private fun maybeReverb() {
        if (PlayerPreferences.reverb == PlayerPreferences.Reverb.None) {
            runCatching {
                reverb?.enabled = false
                player.clearAuxEffectInfo()
                reverb?.release()
            }
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
        val bitmap = if (isAtLeastAndroid13 || AppearancePreferences.isShowingThumbnailInLockscreen)
            bitmapProvider.bitmap else null
        val uri = player.mediaMetadata.artworkUri?.toString()?.thumbnail(512)

        metadataBuilder.putBitmap(MediaMetadata.METADATA_KEY_ART, bitmap)
        metadataBuilder.putString(MediaMetadata.METADATA_KEY_ART_URI, uri)

        metadataBuilder.putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, bitmap)
        metadataBuilder.putString(MediaMetadata.METADATA_KEY_ALBUM_ART_URI, uri)

        if (isAtLeastAndroid13 && player.currentMediaItemIndex == 0) metadataBuilder.putText(
            MediaMetadata.METADATA_KEY_TITLE,
            "${player.mediaMetadata.title} "
        )

        mediaSession.setMetadata(metadataBuilder.build())
    }

    private fun maybeAutoDownload() {
        // This function must run on the main thread to access player
        handler.post {
            try {
                if (!PlayerPreferences.autoDownloadAtHalf) {
                    showDebugNotification("Auto-download disabled")
                    return@post
                }
                
                val currentMediaItem = player.currentMediaItem ?: run {
                    showDebugNotification("No current media item")
                    return@post
                }
                val mediaId = currentMediaItem.mediaId
                
                // Skip if mediaId is null or empty
                if (mediaId.isNullOrBlank()) {
                    showDebugNotification("Media ID is blank")
                    return@post
                }
                
                // Skip if already processed this song
                if (mediaId in autoDownloadedSongs) {
                    showDebugNotification("Already processed: $mediaId")
                    return@post
                }
                
                // Skip if it's a local file (already downloaded)
                if (mediaId.startsWith(LOCAL_KEY_PREFIX)) {
                    showDebugNotification("Local file: $mediaId")
                    return@post
                }
                
                // Skip if it's already a download file
                if (mediaId.startsWith("download:")) {
                    showDebugNotification("Download file: $mediaId")
                    return@post
                }
                
                val duration = player.duration
                val position = player.currentPosition
                val percentage = if (duration > 0 && duration != C.TIME_UNSET) (position * 100 / duration) else 0
                
                // Show progress notification
                val title = currentMediaItem.mediaMetadata.title?.toString() ?: "Unknown"
                showDebugNotification("$title: ${percentage}% (${position}ms/${duration}ms)")
                
                // Check if duration is valid and we've reached 50%
                if (duration > 0 && duration != C.TIME_UNSET && position >= duration / 2) {
                    // Verificar espacio de almacenamiento disponible
                    if (!hasAvailableStorage()) {
                        showDebugNotification("Storage full (95%+), disabling auto-download: $title")
                        // Desactivar el switch de auto-descarga cuando se alcance el límite
                        PlayerPreferences.autoDownloadAtHalf = false
                        // Mostrar toast al usuario explicando la acción
                        handler.post {
                            toast(getString(R.string.auto_download_disabled_storage_full))
                        }
                        // Mark as processed to avoid checking again during this session
                        autoDownloadedSongs.add(mediaId)
                        return@post
                    }
                    
                    // Mark as processed to avoid duplicate downloads
                    autoDownloadedSongs.add(mediaId)
                    
                    showDebugNotification("Starting download: $title")
                    
                    // Start auto-download in background
                    coroutineScope.launch(Dispatchers.IO) {
                        try {
                            // Check if already downloaded
                            val existingDownload = runCatching {
                                Database.downloadedSongs().first().find { it.id == "download:$mediaId" }
                            }.getOrNull()
                            
                            if (existingDownload != null) {
                                showDebugNotification("Already downloaded: $title")
                                return@launch
                            }
                            
                            // Get streaming URL for download
                            showDebugNotification("Getting URL for: $title")
                            val playerResponse = runCatching {
                                Innertube.player(PlayerBody(videoId = mediaId))
                            }.getOrNull()
                            
                            val streamingUrl = playerResponse?.mapCatching { body ->
                                body?.streamingData?.adaptiveFormats?.findLast { format ->
                                    format.itag == 251 || format.itag == 140
                                }?.url
                            }?.getOrNull()
                            
                            if (streamingUrl != null) {
                                val metadata = currentMediaItem.mediaMetadata
                                val artist = metadata.artist?.toString()
                                val album = metadata.albumTitle?.toString()
                                val thumbnailUrl = metadata.artworkUri?.toString()
                                
                                showDebugNotification("Downloading: $title")
                                
                                // Start download using MusicDownloadService
                                MusicDownloadService.download(
                                    context = this@PlayerService,
                                    trackId = mediaId,
                                    title = title,
                                    artist = artist,
                                    album = album,
                                    thumbnailUrl = thumbnailUrl,
                                    duration = if (duration > 0 && duration != C.TIME_UNSET) duration else null,
                                    url = streamingUrl
                                )
                                
                                // Show toast notification
                                withContext(Dispatchers.Main) {
                                    toast(getString(R.string.auto_download_started, title))
                                }
                            } else {
                                showDebugNotification("No URL found for: $title")
                            }
                        } catch (e: Exception) {
                            showDebugNotification("Download failed: ${e.message}")
                        }
                    }
                }
            } catch (e: Exception) {
                showDebugNotification("Error: ${e.message}")
            }
        }
    }

    private fun showDebugNotification(message: String) {
        // Solo mostrar notificaciones de debug en versión debug
        if (!BuildConfig.DEBUG) return
        
        handler.post {
            try {
                ServiceNotifications.autoDownloadDebug.sendNotification(this@PlayerService) {
                    this
                        .setSmallIcon(R.drawable.app_icon)
                        .setContentTitle("Auto-Download Debug")
                        .setContentText(message)
                        .setOngoing(false)
                        .setAutoCancel(true)
                        .setPriority(NotificationCompat.PRIORITY_LOW)
                }
            } catch (e: Exception) {
                // Ignore notification errors
            }
        }
    }

    /**
     * Verifica si hay suficiente espacio de almacenamiento disponible
     * @return true si el almacenamiento está por debajo del 95%, false si está al 95% o más
     */
    private fun hasAvailableStorage(): Boolean {
        return try {
            val stat = StatFs(applicationContext.filesDir.path)
            val totalBytes = stat.blockCountLong * stat.blockSizeLong
            val availableBytes = stat.availableBlocksLong * stat.blockSizeLong
            val usedBytes = totalBytes - availableBytes
            val usagePercentage = (usedBytes.toDouble() / totalBytes.toDouble()) * 100
            
            // Convertir a GB para mejor legibilidad
            val totalGB = totalBytes / (1024.0 * 1024.0 * 1024.0)
            val availableGB = availableBytes / (1024.0 * 1024.0 * 1024.0)
            
            showDebugNotification(
                "Storage: ${usagePercentage.toInt()}% used " +
                "(${String.format("%.1f", availableGB)}GB free / ${String.format("%.1f", totalGB)}GB total)"
            )
            
            val hasSpace = usagePercentage < 95.0
            if (!hasSpace) {
                showDebugNotification("⚠️ Storage limit reached! Auto-download will be disabled.")
            }
            
            hasSpace
        } catch (e: Exception) {
            showDebugNotification("Storage check failed: ${e.message}")
            // En caso de error, permitir la descarga por defecto
            true
        }
    }

    private fun maybeResumePlaybackWhenDeviceConnected() {
        if (!isAtLeastAndroid6) return

        if (!PlayerPreferences.resumePlaybackWhenDeviceConnected) {
            audioManager?.unregisterAudioDeviceCallback(audioDeviceCallback)
            audioDeviceCallback = null
            return
        }
        if (audioManager == null) audioManager = getSystemService<AudioManager>()

        audioDeviceCallback = object : AudioDeviceCallback() {
            private fun canPlayMusic(audioDeviceInfo: AudioDeviceInfo) =
                audioDeviceInfo.isSink && (
                    audioDeviceInfo.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                        audioDeviceInfo.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                        audioDeviceInfo.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES
                    )
                    .let {
                        if (!isAtLeastAndroid8) it else
                            it || audioDeviceInfo.type == AudioDeviceInfo.TYPE_USB_HEADSET
                    }

            override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
                if (!player.isPlaying && addedDevices.any(::canPlayMusic)) player.play()
            }

            override fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) = Unit
        }

        audioManager?.registerAudioDeviceCallback(audioDeviceCallback, handler)
    }

    private fun openEqualizer() =
        EqualizerIntentBundleAccessor.sendOpenEqualizer(player.audioSessionId)

    private fun closeEqualizer() =
        EqualizerIntentBundleAccessor.sendCloseEqualizer(player.audioSessionId)

    private fun updatePlaybackState() = coroutineScope.launch {
        playbackStateMutex.withLock {
            withContext(Dispatchers.Main) {
                mediaSession.setPlaybackState(
                    stateBuilder
                        .setState(
                            player.androidPlaybackState,
                            player.currentPosition,
                            player.playbackParameters.speed,
                            SystemClock.elapsedRealtime()
                        )
                        .setBufferedPosition(player.bufferedPosition)
                        .build()
                )
            }
        }
    }

    private val Player.androidPlaybackState
        get() = when (playbackState) {
            Player.STATE_BUFFERING -> if (playWhenReady) PlaybackState.STATE_BUFFERING else PlaybackState.STATE_PAUSED
            Player.STATE_READY -> if (playWhenReady) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED
            Player.STATE_ENDED -> PlaybackState.STATE_STOPPED
            Player.STATE_IDLE -> PlaybackState.STATE_NONE
            else -> PlaybackState.STATE_NONE
        }

    // legacy behavior may cause inconsistencies, but not available on sdk 24 or lower
    @Suppress("DEPRECATION")
    override fun onEvents(player: Player, events: Player.Events) {
        if (player.duration != C.TIME_UNSET) mediaSession.setMetadata(
            metadataBuilder
                .putText(
                    MediaMetadata.METADATA_KEY_TITLE,
                    player.mediaMetadata.title?.toString().orEmpty()
                )
                .putText(
                    MediaMetadata.METADATA_KEY_ARTIST,
                    player.mediaMetadata.artist?.toString().orEmpty()
                )
                .putText(
                    MediaMetadata.METADATA_KEY_ALBUM,
                    player.mediaMetadata.albumTitle?.toString().orEmpty()
                )
                .putLong(MediaMetadata.METADATA_KEY_DURATION, player.duration)
                .build()
        )

        updatePlaybackState()

        if (
            !events.containsAny(
                Player.EVENT_PLAYBACK_STATE_CHANGED,
                Player.EVENT_PLAY_WHEN_READY_CHANGED,
                Player.EVENT_IS_PLAYING_CHANGED,
                Player.EVENT_POSITION_DISCONTINUITY,
                Player.EVENT_IS_LOADING_CHANGED,
                Player.EVENT_MEDIA_METADATA_CHANGED
            )
        ) return

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
            startForegroundService(this@PlayerService, intent<PlayerService>())
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
    }

    private fun notification(): (NotificationCompat.Builder.() -> NotificationCompat.Builder)? {
        if (player.currentMediaItem == null) return null

        val mediaMetadata = player.mediaMetadata

        bitmapProvider.load(mediaMetadata.artworkUri) {
            maybeShowSongCoverInLockScreen()
            updateNotification()
        }

        return {
            this
                .setContentTitle(mediaMetadata.title?.toString().orEmpty())
                .setContentText(mediaMetadata.artist?.toString().orEmpty())
                .setSubText(player.playerError?.message)
                .setLargeIcon(bitmapProvider.bitmap)
                .setAutoCancel(false)
                .setOnlyAlertOnce(true)
                .setShowWhen(false)
                .setSmallIcon(
                    player.playerError?.let { R.drawable.alert_circle } ?: R.drawable.app_icon
                )
                .setOngoing(false)
                .setContentIntent(
                    activityPendingIntent<MainActivity>(flags = PendingIntent.FLAG_UPDATE_CURRENT)
                )
                .setDeleteIntent(broadcastPendingIntent<NotificationDismissReceiver>())
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
                .addAction(
                    R.drawable.play_skip_back,
                    getString(R.string.skip_back),
                    notificationActionReceiver.previous.pendingIntent
                )
                .let { builder ->
                    if (player.shouldBePlaying) builder.addAction(
                        R.drawable.pause,
                        getString(R.string.pause),
                        notificationActionReceiver.pause.pendingIntent
                    )
                    else builder.addAction(
                        R.drawable.play,
                        getString(R.string.play),
                        notificationActionReceiver.play.pendingIntent
                    )
                }
                .addAction(
                    R.drawable.play_skip_forward,
                    getString(R.string.skip_forward),
                    notificationActionReceiver.next.pendingIntent
                )
                .addAction(
                    if (isLikedState.value) R.drawable.heart else R.drawable.heart_outline,
                    getString(R.string.like),
                    notificationActionReceiver.like.pendingIntent
                )
                .addAction(
                    if (PlayerPreferences.trackLoopEnabled) R.drawable.repeat_on else R.drawable.repeat,
                    getString(R.string.queue_loop),
                    notificationActionReceiver.loop.pendingIntent
                )
                .setStyle(
                    androidx.media.app.NotificationCompat.MediaStyle()
                        .setShowActionsInCompactView(0, 1, 2)
                        .setMediaSession(MediaSessionCompat.Token.fromToken(mediaSession.sessionToken))
                )
        }
    }

    private fun updateNotification() = runCatching {
        handler.post {
            notification()?.let { ServiceNotifications.default.sendNotification(this, it) }
        }
    }

    override fun startForeground() {
        notification()
            ?.let { ServiceNotifications.default.startForeground(this, it) }
    }

    private fun createMediaSourceFactory() = DefaultMediaSourceFactory(
        /* dataSourceFactory = */ createYouTubeDataSourceResolverFactory(
            findMediaItem = { videoId ->
                withContext(Dispatchers.Main) {
                    player.findNextMediaItemById(videoId)
                }
            },
            context = applicationContext,
            cache = cache
        ),
        /* extractorsFactory = */ DefaultExtractorsFactory()
    ).setLoadErrorHandlingPolicy(
        object : DefaultLoadErrorHandlingPolicy() {
            override fun isEligibleForFallback(exception: IOException) = true
        }
    )

    private fun createRendersFactory() = object : DefaultRenderersFactory(this) {
        override fun buildAudioSink(
            context: Context,
            enableFloatOutput: Boolean,
            enableAudioTrackPlaybackParams: Boolean
        ): AudioSink {
            val minimumSilenceDuration =
                PlayerPreferences.minimumSilence.coerceIn(1000L..2_000_000L)

            return DefaultAudioSink.Builder(applicationContext)
                .setEnableFloatOutput(enableFloatOutput)
                .setEnableAudioTrackPlaybackParams(enableAudioTrackPlaybackParams)
                .setAudioOffloadSupportProvider(
                    DefaultAudioOffloadSupportProvider(applicationContext)
                )
                .setAudioProcessorChain(
                    DefaultAudioProcessorChain(
                        arrayOf(),
                        SilenceSkippingAudioProcessor(
                            /* minimumSilenceDurationUs = */ minimumSilenceDuration,
                            /* silenceRetentionRatio = */ 0.01f,
                            /* maxSilenceToKeepDurationUs = */ minimumSilenceDuration,
                            /* minVolumeToKeepPercentageWhenMuting = */ 0,
                            /* silenceThresholdLevel = */ 256
                        ),
                        SonicAudioProcessor()
                    )
                )
                .build()
                .apply {
                    if (isAtLeastAndroid10) setOffloadMode(AudioSink.OFFLOAD_MODE_DISABLED)
                }
        }
    }

    @Stable
    inner class Binder : AndroidBinder() {
        val player: ExoPlayer
            get() = this@PlayerService.player

        val cache: Cache
            get() = this@PlayerService.cache

        val mediaSession
            get() = this@PlayerService.mediaSession

        val sleepTimerMillisLeft: StateFlow<Long?>?
            get() = timerJob?.millisLeft

        private var radioJob: Job? = null

        var isLoadingRadio by mutableStateOf(false)
            private set

        var invincible
            get() = isInvincibilityEnabled
            set(value) {
                isInvincibilityEnabled = value
            }

        val poiTimestamp get() = this@PlayerService.poiTimestamp

        fun setBitmapListener(listener: ((Bitmap?) -> Unit)?) = bitmapProvider.setListener(listener)

        @kotlin.OptIn(FlowPreview::class)
        fun startSleepTimer(delayMillis: Long) {
            timerJob?.cancel()

            timerJob = coroutineScope.timer(delayMillis) {
                ServiceNotifications.sleepTimer.sendNotification(this@PlayerService) {
                    return@sendNotification this
                        .setContentTitle(getString(R.string.sleep_timer_ended))
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                        .setAutoCancel(true)
                        .setOnlyAlertOnce(true)
                        .setShowWhen(true)
                        .setSmallIcon(R.drawable.app_icon)
                }

                handler.post {
                    player.pause()
                    player.stop()

                    glyphInterface.glyph {
                        turnOff()
                    }
                }
            }.also { job ->
                glyphInterface.progress(
                    job
                        .millisLeft
                        .takeWhile { it != null }
                        .debounce(500.milliseconds)
                        .map { ((it ?: 0L) / delayMillis.toFloat() * 100).toInt() }
                )
            }
        }

        fun cancelSleepTimer() {
            timerJob?.cancel()
            timerJob = null
        }

        fun setupRadio(endpoint: NavigationEndpoint.Endpoint.Watch?) =
            startRadio(endpoint = endpoint, justAdd = true)

        fun playRadio(endpoint: NavigationEndpoint.Endpoint.Watch?) =
            startRadio(endpoint = endpoint, justAdd = false)

        private fun startRadio(endpoint: NavigationEndpoint.Endpoint.Watch?, justAdd: Boolean) {
            radioJob?.cancel()
            radio = null

            YouTubeRadio(
                endpoint?.videoId,
                endpoint?.playlistId,
                endpoint?.playlistSetVideoId,
                endpoint?.params
            ).let { radioData ->
                isLoadingRadio = true
                radioJob = coroutineScope.launch {
                    val items = radioData.process().let { Database.filterBlacklistedSongs(it) }

                    withContext(Dispatchers.Main) {
                        if (justAdd) player.addMediaItems(items.drop(1))
                        else player.forcePlayFromBeginning(items)
                    }

                    radio = radioData
                    isLoadingRadio = false
                }
            }
        }

        fun stopRadio() {
            isLoadingRadio = false
            radioJob?.cancel()
            radio = null
        }

        /**
         * This method should ONLY be called when the application (sc. activity) is in the foreground!
         */
        fun restartForegroundOrStop() {
            player.pause()
            isInvincibilityEnabled = false
            stopSelf()
        }

        fun isCached(song: SongWithContentLength) =
            song.contentLength?.let { cache.isCached(song.song.id, 0L, it) } ?: false

        fun playFromSearch(query: String) {
            coroutineScope.launch {
                Innertube.searchPage(
                    body = SearchBody(
                        query = query,
                        params = Innertube.SearchFilter.Song.value
                    ),
                    fromMusicShelfRendererContent = Innertube.SongItem.Companion::from
                )
                    ?.getOrNull()
                    ?.items
                    ?.firstOrNull()
                    ?.info
                    ?.endpoint
                    ?.let { playRadio(it) }
            }
        }
    }

    private fun likeAction() = mediaItemState.value?.let { mediaItem ->
        query {
            runCatching {
                Database.like(
                    songId = mediaItem.mediaId,
                    likedAt = if (isLikedState.value) null else System.currentTimeMillis()
                )
            }
        }
    }.let { }

    private fun loopAction() {
        PlayerPreferences.trackLoopEnabled = !PlayerPreferences.trackLoopEnabled
    }

    private inner class SessionCallback : MediaSession.Callback() {
        override fun onPlay() = player.play()
        override fun onPause() = player.pause()
        override fun onSkipToPrevious() = runCatching(player::forceSeekToPrevious).let { }
        override fun onSkipToNext() = runCatching(player::forceSeekToNext).let { }
        override fun onSeekTo(pos: Long) = player.seekTo(pos)
        override fun onStop() = player.pause()
        override fun onRewind() = player.seekToDefaultPosition()
        override fun onSkipToQueueItem(id: Long) =
            runCatching { player.seekToDefaultPosition(id.toInt()) }.let { }

        override fun onSetPlaybackSpeed(speed: Float) {
            PlayerPreferences.speed = speed.coerceIn(0.01f..2f)
        }

        override fun onPlayFromSearch(query: String?, extras: Bundle?) {
            if (query.isNullOrBlank()) return
            binder.playFromSearch(query)
        }

        override fun onCustomAction(action: String, extras: Bundle?) {
            super.onCustomAction(action, extras)
            when (action) {
                LIKE_ACTION -> likeAction()
                LOOP_ACTION -> loopAction()
            }
        }
    }

    inner class NotificationActionReceiver internal constructor() :
        ActionReceiver("com.rmusic.android") {
        val pause by action { _, _ ->
            player.pause()
        }
        val play by action { _, _ ->
            player.play()
        }
        val next by action { _, _ ->
            player.forceSeekToNext()
        }
        val previous by action { _, _ ->
            player.forceSeekToPrevious()
        }
        val like by action { _, _ ->
            likeAction()
        }
        val loop by action { _, _ ->
            loopAction()
        }
    }

    class NotificationDismissReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            context.stopService(context.intent<PlayerService>())
        }
    }

    companion object {
        private const val DEFAULT_CACHE_DIRECTORY = "exoplayer"
        private const val DEFAULT_CHUNK_LENGTH = 512 * 1024L

        fun createDatabaseProvider(context: Context) = StandaloneDatabaseProvider(context)
        fun createCache(
            context: Context,
            directoryName: String = DEFAULT_CACHE_DIRECTORY,
            size: ExoPlayerDiskCacheSize = DataPreferences.exoPlayerDiskCacheMaxSize
        ) = with(context) {
            val cacheEvictor = when (size) {
                ExoPlayerDiskCacheSize.Unlimited -> NoOpCacheEvictor()
                else -> LeastRecentlyUsedCacheEvictor(size.bytes)
            }

            val directory = cacheDir.resolve(directoryName).apply {
                if (!exists()) mkdir()
            }

            SimpleCache(directory, cacheEvictor, createDatabaseProvider(context))
        }

        @Suppress("CyclomaticComplexMethod")
        fun createYouTubeDataSourceResolverFactory(
            context: Context,
            cache: Cache,
            chunkLength: Long? = DEFAULT_CHUNK_LENGTH,
            findMediaItem: suspend (videoId: String) -> MediaItem? = { null },
            uriCache: UriCache<String, Long?> = UriCache()
        ): DataSource.Factory = ResolvingDataSource.Factory(
            ConditionalCacheDataSourceFactory(
                cacheDataSourceFactory = cache.readOnlyWhen { PlayerPreferences.pauseCache }.asDataSource,
                upstreamDataSourceFactory = context.defaultDataSource,
                shouldCache = { !it.isLocal }
            )
        ) resolver@{ dataSpec ->
            val mediaId = dataSpec.key?.removePrefix("https://youtube.com/watch?v=")
                ?: error("A key must be set")

            fun DataSpec.ranged(contentLength: Long?) = contentLength?.let {
                if (chunkLength == null) return@let null

                val start = dataSpec.uriPositionOffset
                val length = (contentLength - start).coerceAtMost(chunkLength)
                val rangeText = "$start-${start + length}"

                this.subrange(start, length)
                    .withAdditionalHeaders(mapOf("Range" to "bytes=$rangeText"))
            } ?: this

            // Handle local files (cached and downloaded)
            if (dataSpec.isLocal) {
                return@resolver dataSpec
            }

            // Check for downloaded files
            if (mediaId.startsWith("download:")) {
                val downloadedSong = runBlocking(Dispatchers.IO) {
                    Database.downloadedSongs().first().find { it.id == mediaId }
                }
                
                if (downloadedSong != null && File(downloadedSong.filePath).exists()) {
                    return@resolver dataSpec
                        .withUri(File(downloadedSong.filePath).toUri())
                } else {
                    // Downloaded song not found or file doesn't exist
                    throw PlayableFormatNotFoundException()
                }
            }

            if (
                chunkLength != null && cache.isCached(
                    /* key = */ mediaId,
                    /* position = */ dataSpec.position,
                    /* length = */ chunkLength
                )
            ) dataSpec
            else uriCache[mediaId]?.let { cachedUri ->
                dataSpec
                    .withUri(cachedUri.uri)
                    .ranged(cachedUri.meta)
            } ?: run {
                val body = runBlocking(Dispatchers.IO) {
                    Innertube.player(PlayerBody(videoId = mediaId))
                }?.getOrThrow()

                if (body?.videoDetails?.videoId != mediaId) throw VideoIdMismatchException()

                body.reason?.let { Log.w(TAG, it) }
                val format = body.streamingData?.highestQualityFormat
                    ?: throw PlayableFormatNotFoundException()
                val url = when (val status = body.playabilityStatus?.status) {
                    "OK" -> {
                        val mediaItem = runCatching {
                            runBlocking(Dispatchers.IO) { findMediaItem(mediaId) }
                        }.getOrNull()
                        val extras = mediaItem?.mediaMetadata?.extras?.songBundle

                        if (extras?.durationText == null) format.approxDurationMs
                            ?.div(1000)
                            ?.let(DateUtils::formatElapsedTime)
                            ?.removePrefix("0")
                            ?.let { durationText ->
                                extras?.durationText = durationText
                                Database.updateDurationText(mediaId, durationText)
                            }

                        transaction {
                            runCatching {
                                mediaItem?.let(Database::insert)

                                Database.insert(
                                    Format(
                                        songId = mediaId,
                                        itag = format.itag,
                                        mimeType = format.mimeType,
                                        bitrate = format.bitrate,
                                        loudnessDb = body.playerConfig?.audioConfig?.normalizedLoudnessDb,
                                        contentLength = format.contentLength,
                                        lastModified = format.lastModified
                                    )
                                )
                            }
                        }

                        runCatching {
                            runBlocking(Dispatchers.IO) {
                                body.context?.let { format.findUrl(it) }
                            }
                        }.getOrElse {
                            throw RestrictedVideoException(it)
                        }
                    }

                    "UNPLAYABLE" -> throw UnplayableException()
                    "LOGIN_REQUIRED" -> throw LoginRequiredException()

                    else -> throw PlaybackException(
                        /* message = */ status,
                        /* cause = */ null,
                        /* errorCode = */ PlaybackException.ERROR_CODE_REMOTE_ERROR
                    )
                } ?: throw UnplayableException()

                val uri = url.toUri().let {
                    if (body.cpn == null) it
                    else it
                        .buildUpon()
                        .appendQueryParameter("cpn", body.cpn)
                        .build()
                }

                uriCache.push(
                    key = mediaId,
                    meta = format.contentLength,
                    uri = uri,
                    validUntil = body.streamingData?.expiresInSeconds?.seconds?.let { Clock.System.now() + it }
                )

                dataSpec.withUri(uri).ranged(format.contentLength)
            }
        }.handleUnknownErrors {
            uriCache.clear()
        }.retryIf<UnplayableException>(
            maxRetries = 2,
            printStackTrace = true
        ).retryIf(
            maxRetries = 1,
            printStackTrace = true
        ) { ex ->
            ex.findCause<InvalidResponseCodeException>()?.responseCode == 403 ||
                ex.findCause<ClientRequestException>()?.response?.status?.value == 403 ||
                ex.findCause<InvalidHttpCodeException>() != null
        }.handleRangeErrors().withFallback(context) { dataSpec ->
            val id = dataSpec.key ?: error("No id found for resolving an alternative song")
            val alternativeSong = runBlocking(Dispatchers.IO) {
                Database
                    .localSongsByRowIdDesc()
                    .first()
                    .find { id in it.title }
            } ?: error("No alternative song found")

            dataSpec.buildUpon()
                .setKey(alternativeSong.id)
                .setUri(
                    ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                        alternativeSong.id.substringAfter(LOCAL_KEY_PREFIX).toLong()
                    )
                )
                .build()
        }
    }
}
