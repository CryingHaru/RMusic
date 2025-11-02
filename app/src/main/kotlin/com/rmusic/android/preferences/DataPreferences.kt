package com.rmusic.android.preferences

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.core.content.edit
import com.rmusic.android.GlobalPreferencesHolder
import com.rmusic.android.R
import com.rmusic.core.data.enums.CoilDiskCacheSize
import com.rmusic.core.data.enums.ExoPlayerDiskCacheSize
import com.rmusic.providers.innertube.Innertube
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlin.time.Duration
import kotlin.time.Duration.Companion.days
import kotlin.time.Duration.Companion.hours

object DataPreferences : GlobalPreferencesHolder() {
    var coilDiskCacheMaxSize by enum(CoilDiskCacheSize.`128MB`)
    var exoPlayerDiskCacheMaxSize by enum(ExoPlayerDiskCacheSize.`2GB`)
    var cacheSizePercent by int(50)
    var pauseHistory by boolean(false)
    var pausePlaytime by boolean(false)
    var pauseSearchHistory by boolean(false)
    val topListLengthProperty = int(50)
    var topListLength by topListLengthProperty
    val topListPeriodProperty = enum(TopListPeriod.AllTime)
    var topListPeriod by topListPeriodProperty
    var quickPicksSource by enum(QuickPicksSource.Trending)
    var versionCheckPeriod by enum(VersionCheckPeriod.Off)
    var shouldCacheQuickPicks by boolean(true)
    var quickPicksSnapshot by json(
        defaultValue = QuickPicksSnapshot(),
        serializer = QuickPicksSnapshot.serializer()
    )
    var cachedQuickPicks: Innertube.RelatedPage
        get() = quickPicksSnapshot.related ?: Innertube.RelatedPage()
        set(value) {
            quickPicksSnapshot = quickPicksSnapshot.copy(
                related = value.takeIf { it.hasContent() },
                trending = quickPicksSnapshot.trending,
                timestamp = if (value.hasContent()) System.currentTimeMillis() else quickPicksSnapshot.timestamp
            )
        }
    var autoSyncPlaylists by boolean(true)

    init {
        migrateLegacyQuickPicks()
    }
    
    // Download preferences
    var wifiOnlyDownloads by boolean(true)
    var downloadQuality by enum(DownloadQuality.High)

    enum class TopListPeriod(
        val displayName: @Composable () -> String,
        val duration: Duration? = null
    ) {
        PastDay(displayName = { stringResource(R.string.past_24_hours) }, duration = 1.days),
        PastWeek(displayName = { stringResource(R.string.past_week) }, duration = 7.days),
        PastMonth(displayName = { stringResource(R.string.past_month) }, duration = 30.days),
        PastYear(displayName = { stringResource(R.string.past_year) }, 365.days),
        AllTime(displayName = { stringResource(R.string.all_time) })
    }

    enum class QuickPicksSource(val displayName: @Composable () -> String) {
        Trending(displayName = { stringResource(R.string.trending) }),
        LastInteraction(displayName = { stringResource(R.string.last_interaction) })
    }

    enum class VersionCheckPeriod(
        val displayName: @Composable () -> String,
        val period: Duration?
    ) {
        Off(displayName = { stringResource(R.string.off_text) }, period = null),
        Hourly(displayName = { stringResource(R.string.hourly) }, period = 1.hours),
        Daily(displayName = { stringResource(R.string.daily) }, period = 1.days),
        Weekly(displayName = { stringResource(R.string.weekly) }, period = 7.days)
    }
    
    enum class DownloadQuality(
        val displayName: @Composable () -> String,
        val bitrate: Int
    ) {
        High(displayName = { stringResource(R.string.high_quality) }, bitrate = 160)  // YouTube's actual max ~160kbps AAC
    }

    private fun migrateLegacyQuickPicks() {
        if (quickPicksSnapshot.hasContent()) return

        val legacyRaw = getString("cachedQuickPicks", null) ?: return
        runCatching {
            legacyQuickPicksJson.decodeFromString(Innertube.RelatedPage.serializer(), legacyRaw)
        }.onSuccess { legacyPage ->
            if (!legacyPage.hasContent()) return@onSuccess

            quickPicksSnapshot = QuickPicksSnapshot(
                trending = quickPicksSnapshot.trending,
                related = legacyPage,
                timestamp = System.currentTimeMillis()
            )

            edit(commit = true) { remove("cachedQuickPicks") }
        }
    }

    private val legacyQuickPicksJson = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        isLenient = true
    }
}
