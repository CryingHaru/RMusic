package com.rmusic.android.ui.screens.settings

import android.text.format.Formatter
import android.os.StatFs
import androidx.annotation.OptIn
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.media3.common.util.UnstableApi
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.preferences.PlayerPreferences
import com.rmusic.android.ui.components.themed.LinearProgressIndicator
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.screens.settings.EnumValueSelectorSettingsEntry
import com.rmusic.android.ui.screens.settings.SliderSettingsEntry
import com.rmusic.android.ui.screens.settings.SettingsCategoryScreen
import com.rmusic.android.ui.screens.settings.SettingsDescription
import com.rmusic.android.ui.screens.settings.SettingsGroup
import com.rmusic.android.ui.screens.settings.SwitchSettingsEntry
import com.rmusic.android.ui.screens.Route
import com.rmusic.core.data.enums.ExoPlayerDiskCacheSize
import coil3.imageLoader

@OptIn(UnstableApi::class)
@Route
@Composable
fun CacheSettings() = with(DataPreferences) {
    val context = LocalContext.current
    val binder = LocalPlayerServiceBinder.current
    val imageCache = remember(context) { context.imageLoader.diskCache }

    SettingsCategoryScreen(title = stringResource(R.string.cache)) {
        SettingsDescription(text = stringResource(R.string.cache_description))

        var imageCacheSize by remember(imageCache) { mutableLongStateOf(imageCache?.size ?: 0L) }
        imageCache?.let { diskCache ->
            val formattedSize = remember(imageCacheSize) {
                Formatter.formatShortFileSize(context, imageCacheSize)
            }
            val sizePercentage = remember(imageCacheSize, coilDiskCacheMaxSize) {
                imageCacheSize.toFloat() / coilDiskCacheMaxSize.bytes.coerceAtLeast(1)
            }

            SettingsGroup(
                title = stringResource(R.string.image_cache),
                description = stringResource(
                    R.string.format_cache_space_used_percentage,
                    formattedSize,
                    (sizePercentage * 100).toInt()
                ),
                trailingContent = {
                    SecondaryTextButton(
                        text = stringResource(R.string.clear),
                        onClick = {
                            diskCache.clear()
                            imageCacheSize = 0L
                        },
                        modifier = Modifier.padding(end = 12.dp)
                    )
                }
            ) {
                LinearProgressIndicator(
                    progress = sizePercentage,
                    strokeCap = StrokeCap.Round,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp)
                        .padding(start = 32.dp, end = 16.dp)
                )
                EnumValueSelectorSettingsEntry(
                    title = stringResource(R.string.max_size),
                    selectedValue = coilDiskCacheMaxSize,
                    onValueSelect = { coilDiskCacheMaxSize = it }
                )
            }
        }
        binder?.cache?.let { cache ->
            // Compute available device space minus 1GB for system
            val totalSpace = remember(context) {
                val stat = StatFs(context.filesDir.absolutePath)
                stat.blockSizeLong * stat.blockCountLong - 1024L * 1024 * 1024
            }
            // Compute cache max bytes based on user percentage
            var percent by remember { mutableIntStateOf(DataPreferences.cacheSizePercent) }
            val cacheMaxBytes = remember(percent, totalSpace) { totalSpace * percent / 100L }
            val formattedMax = remember(cacheMaxBytes) { Formatter.formatShortFileSize(context, cacheMaxBytes) }
            SettingsDescription(text = stringResource(R.string.cache_description))
            SliderSettingsEntry(
                title = stringResource(R.string.max_size),
                text = stringResource(R.string.cache_description),
                state = percent.toFloat(),
                range = 1f..100f,
                steps = 98,
                toDisplay = { formattedMax },
                onSlide = {
                    percent = it.toInt()
                },
                onSlideComplete = {
                    DataPreferences.cacheSizePercent = percent
                }
            )
            Spacer(modifier = Modifier.height(12.dp))
            val diskCacheSize by remember { derivedStateOf { cache.cacheSpace } }
            val formattedSize = remember(diskCacheSize) {
                Formatter.formatShortFileSize(context, diskCacheSize)
            }
            val sizePercentage = remember(diskCacheSize, exoPlayerDiskCacheMaxSize) {
                diskCacheSize.toFloat() / exoPlayerDiskCacheMaxSize.bytes.coerceAtLeast(1)
            }

            SettingsGroup(
                title = stringResource(R.string.song_cache),
                description = if (exoPlayerDiskCacheMaxSize == ExoPlayerDiskCacheSize.Unlimited) stringResource(
                    R.string.format_cache_space_used,
                    formattedSize
                )
                else stringResource(
                    R.string.format_cache_space_used_percentage,
                    formattedSize,
                    (sizePercentage * 100).toInt()
                )
            ) {
                AnimatedVisibility(visible = exoPlayerDiskCacheMaxSize != ExoPlayerDiskCacheSize.Unlimited) {
                    LinearProgressIndicator(
                        progress = sizePercentage,
                        strokeCap = StrokeCap.Round,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 12.dp)
                            .padding(start = 32.dp, end = 16.dp)
                    )
                }
                SwitchSettingsEntry(
                    title = stringResource(R.string.pause_song_cache),
                    text = stringResource(R.string.pause_song_cache_description),
                    isChecked = PlayerPreferences.pauseCache,
                    onCheckedChange = { PlayerPreferences.pauseCache = it }
                )
            }
        }
    }
}
