package com.rmusic.android

import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import android.os.Bundle
import android.os.IBinder
import android.os.StrictMode
import android.os.StrictMode.VmPolicy
import android.provider.MediaStore
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.LocalIndication
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.BoxWithConstraintsScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.add
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.displayCutout
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.isImeVisible
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBars
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LocalRippleConfiguration
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.zIndex
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.coerceAtLeast
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.core.view.WindowCompat
import androidx.credentials.CredentialManager
import androidx.lifecycle.ViewModel
import androidx.lifecycle.lifecycleScope
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.work.Configuration
import com.rmusic.android.preferences.AppearancePreferences
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.service.PlayerService
import com.rmusic.android.service.ServiceNotifications
import com.rmusic.android.service.downloadState as musicDownloadState
import com.rmusic.android.ui.components.BottomSheetMenu
import com.rmusic.android.ui.components.rememberBottomSheetState
import com.rmusic.android.ui.components.themed.LinearProgressIndicator
import com.rmusic.android.ui.screens.albumRoute
import com.rmusic.android.ui.screens.artistRoute
import com.rmusic.android.ui.screens.home.HomeScreen
import com.rmusic.android.ui.screens.player.Player
import com.rmusic.android.ui.screens.player.Thumbnail
import com.rmusic.android.ui.screens.playlistRoute
import com.rmusic.android.ui.screens.searchResultRoute
import com.rmusic.android.ui.screens.settingsRoute
import com.rmusic.android.utils.DisposableListener
import com.rmusic.android.utils.KeyedCrossfade
import com.rmusic.android.utils.LocalMonetCompat
// deduped import remains above
import com.rmusic.providers.ytmusic.pages.SongResult as YTSongResult
import com.rmusic.android.utils.collectProvidedBitmapAsState
import com.rmusic.android.utils.forcePlay
import com.rmusic.android.utils.intent
import com.rmusic.android.utils.invokeOnReady
import com.rmusic.android.utils.isInPip
import com.rmusic.android.utils.maybeEnterPip
import com.rmusic.android.utils.maybeExitPip
import com.rmusic.android.utils.setDefaultPalette
import com.rmusic.android.utils.shouldBePlaying
import com.rmusic.android.utils.toast
import com.rmusic.compose.persist.LocalPersistMap
import com.rmusic.compose.persist.PersistMap
import com.rmusic.compose.preferences.PreferencesHolder
import com.rmusic.core.ui.Darkness
import com.rmusic.core.ui.Dimensions
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.core.ui.SystemBarAppearance
import com.rmusic.core.ui.amoled
import com.rmusic.core.ui.appearance
import com.rmusic.core.ui.rippleConfiguration
import com.rmusic.core.ui.shimmerTheme
import com.rmusic.core.ui.utils.activityIntentBundle
import com.rmusic.core.ui.utils.isAtLeastAndroid12
import com.rmusic.core.ui.utils.songBundle
import com.rmusic.providers.innertube.Innertube
import com.rmusic.providers.innertube.models.bodies.BrowseBody
import com.rmusic.providers.innertube.requests.playlistPage
import com.rmusic.providers.ytmusic.YTMusicProvider
import com.rmusic.android.utils.asMediaItem
import com.rmusic.providers.innertube.requests.song
import coil3.ImageLoader
import coil3.PlatformContext
import coil3.SingletonImageLoader
import coil3.bitmapFactoryExifOrientationStrategy
import coil3.decode.ExifOrientationStrategy
import coil3.disk.DiskCache
import coil3.disk.directory
import coil3.memory.MemoryCache
import coil3.request.crossfade
import coil3.util.DebugLogger
import com.kieronquinn.monetcompat.core.MonetActivityAccessException
import com.kieronquinn.monetcompat.core.MonetCompat
import com.kieronquinn.monetcompat.interfaces.MonetColorsChangedListener
import com.valentinilk.shimmer.LocalShimmerTheme
import dev.kdrag0n.monet.theme.ColorScheme
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

private const val TAG = "MainActivity"
private val coroutineScope = CoroutineScope(Dispatchers.IO)

// Viewmodel in order to avoid recreating the entire Player state (WORKAROUND)
class MainViewModel : ViewModel() {
    var binder: PlayerService.Binder? by mutableStateOf(null)

    suspend fun awaitBinder(): PlayerService.Binder =
        binder ?: snapshotFlow { binder }.filterNotNull().first()
}

class MainActivity : ComponentActivity(), MonetColorsChangedListener {
    private val vm: MainViewModel by viewModels()

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            if (service is PlayerService.Binder) vm.binder = service
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            vm.binder = null
            // Try to rebind, otherwise fail
            unbindService(this)
            bindService(intent<PlayerService>(), this, BIND_AUTO_CREATE)
        }
    }

    private var _monet: MonetCompat? by mutableStateOf(null)
    private val monet get() = _monet ?: throw MonetActivityAccessException()

    override fun onStart() {
        super.onStart()
    // Ensure the playback service is a started service so it survives unbind when app goes background
    // Starting it while activity is in foreground avoids background start restrictions
    startService(intent<PlayerService>())
    bindService(intent<PlayerService>(), serviceConnection, BIND_AUTO_CREATE)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check and request storage permissions immediately
        com.rmusic.android.utils.PermissionManager.checkAndRequestStoragePermissions(this)

        WindowCompat.setDecorFitsSystemWindows(window, false)

        MonetCompat.setup(this)
        _monet = MonetCompat.getInstance()
        monet.setDefaultPalette()
        monet.addMonetColorsChangedListener(
            listener = this,
            notifySelf = false
        )
        monet.updateMonetColors()
        monet.invokeOnReady {
            setContent()
        }

        intent?.let { handleIntent(it) }
        addOnNewIntentListener(::handleIntent)
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    fun AppWrapper(
        modifier: Modifier = Modifier,
        content: @Composable BoxWithConstraintsScope.() -> Unit
    ) = with(AppearancePreferences) {
        val sampleBitmap = vm.binder.collectProvidedBitmapAsState()
        val appearance = appearance(
            source = colorSource,
            mode = colorMode,
            darkness = darkness,
            fontFamily = fontFamily,
            materialAccentColor = Color(monet.getAccentColor(this@MainActivity)),
            sampleBitmap = sampleBitmap,
            applyFontPadding = applyFontPadding,
            thumbnailRoundness = thumbnailRoundness.dp
        )

        SystemBarAppearance(palette = appearance.colorPalette)

        BoxWithConstraints(
            modifier = Modifier.background(appearance.colorPalette.background0) then modifier.fillMaxSize()
        ) {
            CompositionLocalProvider(
                LocalAppearance provides appearance,
                LocalPlayerServiceBinder provides vm.binder,
                LocalCredentialManager provides Dependencies.credentialManager,
                LocalIndication provides ripple(),
                LocalRippleConfiguration provides rippleConfiguration(appearance = appearance),
                LocalShimmerTheme provides shimmerTheme(),
                LocalLayoutDirection provides LayoutDirection.Ltr,
                LocalPersistMap provides Dependencies.application.persistMap,
                LocalMonetCompat provides monet
            ) {
                content()
            }
        }
    }

    @Suppress("CyclomaticComplexMethod")
    @OptIn(ExperimentalLayoutApi::class)
    fun setContent() = setContent {
        val windowInsets = WindowInsets.systemBars

        AppWrapper(
            modifier = Modifier.padding(
                WindowInsets
                    .displayCutout
                    .only(WindowInsetsSides.Horizontal)
                    .asPaddingValues()
            )
        ) {
            val density = LocalDensity.current
            val bottomDp = with(density) { windowInsets.getBottom(density).toDp() }

            val imeVisible = WindowInsets.isImeVisible
            val imeBottomDp = with(density) { WindowInsets.ime.getBottom(density).toDp() }
            val animatedBottomDp by animateDpAsState(
                targetValue = if (imeVisible) 0.dp else bottomDp,
                label = ""
            )

            val extraCollapsedPadding = with(density) { 3f.toDp() }

            val playerBottomSheetState = rememberBottomSheetState(
                key = vm.binder,
                dismissedBound = 0.dp,
                // Altura colapsada = alto real del mini player (sin insets). El clearance sobre la barra se maneja en BottomSheet.
                collapsedBound = Dimensions.items.collapsedPlayerHeight + extraCollapsedPadding,
                expandedBound = maxHeight
            )

            val playerAwareWindowInsets = remember(
                bottomDp,
                animatedBottomDp,
                playerBottomSheetState.value,
                imeVisible,
                imeBottomDp
            ) {
                val extraGap = if (playerBottomSheetState.collapsed) 8.dp else 0.dp
                val playerPadding = Dimensions.items.bottomNavigationHeight + extraGap
                val playerValue = playerBottomSheetState.value + playerPadding
                val bottom =
                    if (imeVisible) imeBottomDp.coerceAtLeast(playerValue)
                    else playerValue.coerceIn(
                        animatedBottomDp..(playerBottomSheetState.collapsedBound + playerPadding)
                    )

                windowInsets
                    .only(WindowInsetsSides.Horizontal + WindowInsetsSides.Top)
                    .add(WindowInsets(bottom = bottom))
            }

            val pip = isInPip(
                onChange = {
                    if (!it || vm.binder?.player?.shouldBePlaying != true) return@isInPip
                    playerBottomSheetState.expandSoft()
                }
            )

            KeyedCrossfade(state = pip) { currentPip ->
                if (currentPip) Thumbnail(
                    isShowingLyrics = true,
                    onShowLyrics = { },
                    isShowingStatsForNerds = false,
                    onShowStatsForNerds = { },
                    onOpenDialog = { },
                    likedAt = null,
                    setLikedAt = { },
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.FillBounds,
                    shouldShowSynchronizedLyrics = true,
                    setShouldShowSynchronizedLyrics = { },
                    showLyricsControls = false
                ) else CompositionLocalProvider(
                    LocalPlayerAwareWindowInsets provides playerAwareWindowInsets
                ) {
                    val isDownloading by musicDownloadState.collectAsState()

                    Box {
                        HomeScreen()
                    }

                    AnimatedVisibility(
                        visible = isDownloading,
                        modifier = Modifier.padding(playerAwareWindowInsets.asPaddingValues())
                    ) {
                        LinearProgressIndicator(
                            modifier = Modifier
                                .fillMaxWidth()
                                .align(Alignment.TopCenter)
                        )
                    }

                    CompositionLocalProvider(
                        LocalAppearance provides LocalAppearance.current.let {
                            if (it.colorPalette.isDark && AppearancePreferences.darkness == Darkness.AMOLED) {
                                it.copy(colorPalette = it.colorPalette.amoled())
                            } else it
                        }
                    ) {
                        Player(
                            layoutState = playerBottomSheetState,
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .zIndex(2f)
                        )
                    }

                    BottomSheetMenu(
                        modifier = Modifier.align(Alignment.BottomCenter)
                    )
                }
            }

            vm.binder?.player.DisposableListener {
                object : Player.Listener {
                    override fun onMediaItemTransition(
                        mediaItem: MediaItem?,
                        reason: Int
                    ) = when {
                        mediaItem == null -> {
                            maybeExitPip()
                            playerBottomSheetState.dismissSoft()
                        }

                        reason == Player.MEDIA_ITEM_TRANSITION_REASON_PLAYLIST_CHANGED &&
                            mediaItem.mediaMetadata.extras?.songBundle?.isFromPersistentQueue != true -> {
                            if (AppearancePreferences.openPlayer) playerBottomSheetState.expandSoft()
                            else Unit
                        }

                        playerBottomSheetState.dismissed -> playerBottomSheetState.collapseSoft()

                        else -> Unit
                    }
                }
            }
        }
    }

    @Suppress("CyclomaticComplexMethod")
    private fun handleIntent(intent: Intent) = lifecycleScope.launch(Dispatchers.IO) {
        val extras = intent.extras?.activityIntentBundle

        when (intent.action) {
            Intent.ACTION_SEARCH -> {
                val query = extras?.query ?: return@launch
                extras.query = null

                searchResultRoute.ensureGlobal(query)
            }

            Intent.ACTION_APPLICATION_PREFERENCES -> settingsRoute.ensureGlobal()

            Intent.ACTION_VIEW, Intent.ACTION_SEND -> {
                val uri = intent.data
                    ?: runCatching { extras?.text?.toUri() }.getOrNull()
                    ?: return@launch

                intent.data = null
                extras?.text = null

                handleUrl(uri, vm.awaitBinder())
            }

            MediaStore.INTENT_ACTION_MEDIA_PLAY_FROM_SEARCH -> {
                val query = when (extras?.mediaFocus) {
                    null, "vnd.android.cursor.item/*" -> extras?.query ?: extras?.text
                    MediaStore.Audio.Genres.ENTRY_CONTENT_TYPE -> extras.genre
                    MediaStore.Audio.Artists.ENTRY_CONTENT_TYPE -> extras.artist
                    MediaStore.Audio.Albums.ENTRY_CONTENT_TYPE -> extras.album
                    "vnd.android.cursor.item/audio" -> listOfNotNull(
                        extras.album,
                        extras.artist,
                        extras.genre,
                        extras.title
                    ).joinToString(separator = " ")

                    @Suppress("deprecation")
                    MediaStore.Audio.Playlists.ENTRY_CONTENT_TYPE -> extras.playlist

                    else -> null
                }

                if (!query.isNullOrBlank()) vm.awaitBinder().playFromSearch(query)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        monet.removeMonetColorsChangedListener(this)
        _monet = null

        removeOnNewIntentListener(::handleIntent)
    }

    override fun onStop() {
        unbindService(serviceConnection)
        super.onStop()
    }

    override fun onMonetColorsChanged(
        monet: MonetCompat,
        monetColors: ColorScheme,
        isInitialChange: Boolean
    ) {
        if (!isInitialChange) recreate()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()

        if (AppearancePreferences.autoPip && vm.binder?.player?.shouldBePlaying == true) maybeEnterPip()
    }
}

context(Context)
@Suppress("CyclomaticComplexMethod")
fun handleUrl(
    uri: Uri,
    binder: PlayerService.Binder?
) {
    val path = uri.pathSegments.firstOrNull()
    Log.d(TAG, "Opening url: $uri ($path)")

    coroutineScope.launch {
        when (path) {
            "search" -> uri.getQueryParameter("q")?.let { query ->
                searchResultRoute.ensureGlobal(query)
            }

            "playlist" -> uri.getQueryParameter("list")?.let { playlistId ->
                val browseId = "VL$playlistId"

                if (playlistId.startsWith("OLAK5uy_")) Innertube.playlistPage(
                    body = BrowseBody(browseId = browseId)
                )
                    ?.getOrNull()
                    ?.let { page ->
                        page.songsPage?.items?.firstOrNull()?.album?.endpoint?.browseId
                            ?.let { albumRoute.ensureGlobal(it) }
                    } ?: withContext(Dispatchers.Main) {
                    toast(getString(R.string.error_url, uri))
                }
                else playlistRoute.ensureGlobal(
                    p0 = browseId,
                    p1 = uri.getQueryParameter("params"),
                    p2 = null,
                    p3 = playlistId.startsWith("RDCLAK5uy_")
                )
            }

            "channel", "c" -> uri.lastPathSegment?.let { channelId ->
                artistRoute.ensureGlobal(channelId)
            }

            else -> when {
                path == "watch" -> uri.getQueryParameter("v")
                uri.host == "youtu.be" -> path
                else -> {
                    withContext(Dispatchers.Main) {
                        toast(getString(R.string.error_url, uri))
                    }
                    null
                }
                    }?.let { videoId ->
                        // Prefer YTMusic provider first
                        val ytProvider = YTMusicProvider.shared()
                        val ytSong = ytProvider.getPlayer(videoId).getOrNull()
                        if (ytSong != null) withContext(Dispatchers.Main) {
                            binder?.player?.let { p -> p.forcePlay((ytSong as YTSongResult).asMediaItem) }
                        } else {
                            Innertube.song(videoId)?.getOrNull()?.let { song ->
                                withContext(Dispatchers.Main) {
                                    binder?.player?.let { p -> p.forcePlay(song.asMediaItem) }
                                }
                            }
                        }
            }
        }
    }
}

val LocalPlayerServiceBinder = staticCompositionLocalOf<PlayerService.Binder?> { null }
val LocalPlayerAwareWindowInsets =
    compositionLocalOf<WindowInsets> { error("No player insets provided") }
val LocalCredentialManager = staticCompositionLocalOf { Dependencies.credentialManager }

class MainApplication : Application(), SingletonImageLoader.Factory, Configuration.Provider {
    private fun installCrashLogger() {
        val previousHandler = Thread.getDefaultUncaughtExceptionHandler()

        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            runCatching {
                val ts = java.time.ZonedDateTime.now().toString()
                val sb = StringBuilder()
                    .appendLine("===== CRASH @ $ts =====")
                    .appendLine("Thread: ${thread.name} (${thread.id})")
                    .appendLine("App: ${BuildConfig.APPLICATION_ID} ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})")
                    .appendLine("Android: ${android.os.Build.VERSION.SDK_INT} (${android.os.Build.VERSION.RELEASE})")
                    .appendLine("Device: ${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}")
                    .appendLine()
                val sw = java.io.StringWriter()
                val pw = java.io.PrintWriter(sw)
                throwable.printStackTrace(pw)
                pw.flush()
                sb.appendLine(sw.toString())

                // Preferred location: main external storage root (scoped by MANAGE_EXTERNAL_STORAGE on Android 11+)
                val candidatePaths = buildList<java.io.File> {
                    val externalRoot = try {
                        android.os.Environment.getExternalStorageDirectory()
                    } catch (_: Throwable) { null }
                    if (externalRoot != null) add(java.io.File(externalRoot, "crash.log"))

                    // App-specific external dir
                    getExternalFilesDir(null)?.let { add(java.io.File(it.parentFile?.parentFile ?: it, "crash.log")) }
                    getExternalFilesDir(null)?.let { add(java.io.File(it, "crash.log")) }

                    // Internal files dir as last resort
                    filesDir?.let { add(java.io.File(it, "crash.log")) }
                }

                var wrote = false
                for (target in candidatePaths) {
                    wrote = runCatching {
                        target.parentFile?.mkdirs()
        val LocalBottomBarHeight = compositionLocalOf { Dimensions.items.bottomNavigationHeight }
                        java.io.FileOutputStream(target, /* append = */ true).use { fos ->
                            fos.write(sb.toString().toByteArray())
                            fos.flush()
                        }
                        true
                    }.getOrElse { false }
                    if (wrote) break
                }
            }
            // Always delegate to previous handler to keep default crash behavior
            previousHandler?.uncaughtException(thread, throwable)
        }
    }

    override fun onCreate() {
    // Install global crash handler that writes a crash.log to main storage (with fallbacks)
    installCrashLogger()

        StrictMode.setVmPolicy(
            VmPolicy.Builder()
                .let {
                    if (isAtLeastAndroid12) it.detectUnsafeIntentLaunch()
                    else it
                }
                .penaltyLog()
                .penaltyDeath()
                .build()
        )

        MonetCompat.debugLog = BuildConfig.DEBUG
        super.onCreate()

        Dependencies.init(this)
        MonetCompat.enablePaletteCompat()
        ServiceNotifications.createAll()

        // Attempt to restore previously saved YTMusic authentication session (non-blocking)
        // This runs once per process start so that Settings screen & playback logic immediately
        // see an authenticated provider if the user logged in earlier.
        kotlinx.coroutines.GlobalScope.launch(kotlinx.coroutines.Dispatchers.IO) {
            runCatching {
                val provider = com.rmusic.providers.ytmusic.YTMusicProvider.shared()
                // 1) Pre-cargar visitorData desde preferencias si existe
                val vdPrefs = getSharedPreferences("ytmusic_boot", Context.MODE_PRIVATE)
                vdPrefs.getString("visitorData", null)?.let { provider.visitorData = it }

                // 2) Restaurar sesión si hay estado guardado
                if (!provider.isLoggedIn()) {
                    val prefs = getSharedPreferences("ytmusic_auth", Context.MODE_PRIVATE)
                    val raw = prefs.getString("session_state", null)
                    if (!raw.isNullOrBlank()) {
                        val state = Json.decodeFromString(
                            com.rmusic.providers.ytmusic.models.account.AuthenticationState.serializer(),
                            raw
                        )
                        provider.importSessionData(state)
                    }
                }

                // 3) Asegurar visitorData para funcionamiento básico si aún falta y persistirla
                if (provider.visitorData.isNullOrBlank()) {
                    provider.ensureVisitorData()?.let { vd ->
                        vdPrefs.edit().putString("visitorData", vd).apply()
                    }
                }
            }.onFailure { err ->
                if (BuildConfig.DEBUG) android.util.Log.w("YTMusicRestore", "Failed to restore YTMusic session", err)
            }
        }
    }

    override fun newImageLoader(context: PlatformContext) = ImageLoader.Builder(this)
        .crossfade(true)
        .memoryCache {
            MemoryCache.Builder()
                .maxSizePercent(context, 0.1)
                .build()
        }
        .diskCache {
            DiskCache.Builder()
                .directory(context.cacheDir.resolve("coil"))
                .maxSizeBytes(DataPreferences.coilDiskCacheMaxSize.bytes)
                .build()
        }
        .bitmapFactoryExifOrientationStrategy(ExifOrientationStrategy.IGNORE)
    .let { builder: ImageLoader.Builder -> if (BuildConfig.DEBUG) builder.logger(DebugLogger()) else builder }
        .build()

    val persistMap = PersistMap()

    override val workManagerConfiguration = Configuration.Builder()
        .setMinimumLoggingLevel(if (BuildConfig.DEBUG) Log.DEBUG else Log.INFO)
        .build()
}

object Dependencies {
    lateinit var application: MainApplication
        private set

    val credentialManager by lazy { CredentialManager.create(application) }

    internal fun init(application: MainApplication) {
        this.application = application
        DatabaseInitializer()
    }
}

open class GlobalPreferencesHolder : PreferencesHolder(Dependencies.application, "preferences")
