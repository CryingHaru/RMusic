package com.rmusic.android.ui.screens.settings

import android.text.format.Formatter
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import coil3.imageLoader
import com.rmusic.android.Database
import com.rmusic.android.LocalPlayerServiceBinder
import com.rmusic.android.R
import com.rmusic.android.preferences.DataPreferences
import com.rmusic.android.preferences.PlayerPreferences
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.android.ui.screens.Route
import com.rmusic.core.data.enums.CoilDiskCacheSize
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.io.File

@Route
@Composable
fun DownloadSettings() = with(DataPreferences) {
    val context = LocalContext.current
    val binder = LocalPlayerServiceBinder.current
    val imageCache = remember(context) { context.imageLoader.diskCache }

    SettingsCategoryScreen(title = stringResource(R.string.downloads)) {
        SettingsDescription(text = stringResource(R.string.download_description))

        // Image cache section (keep this as it's still relevant)
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

        // Downloaded music section
        val downloadsCount by Database.downloadedSongsCount().collectAsState(initial = 0)
        val totalDownloadSize by Database.totalDownloadedSize().collectAsState(initial = 0L)
        
        val formattedDownloadSize = remember(totalDownloadSize) {
            Formatter.formatShortFileSize(context, totalDownloadSize ?: 0L)
        }

        SettingsGroup(
            title = stringResource(R.string.downloaded_music),
            description = if (downloadsCount > 0) {
                stringResource(
                    R.string.format_downloads_info,
                    downloadsCount,
                    formattedDownloadSize
                )
            } else {
                stringResource(R.string.no_downloads_yet)
            },
            trailingContent = if (downloadsCount > 0) {
                {
                    SecondaryTextButton(
                        text = stringResource(R.string.clear_all),
                        onClick = {
                            // Clear all downloads
                            runBlocking {
                                withContext(Dispatchers.IO) {
                                    // Get all downloaded songs and delete their files
                                    val downloadedSongs = Database.downloadedSongs()
                                    // This would need to be implemented properly
                                    // For now, just clear the database entries
                                }
                            }
                        },
                        modifier = Modifier.padding(end = 12.dp)
                    )
                }
            } else null
        ) {
            if (downloadsCount > 0) {
                // Storage location info
                SettingsEntry(
                    title = stringResource(R.string.storage_location),
                    text = stringResource(R.string.download_location_description),
                    onClick = { /* Could open file manager to downloads folder */ }
                )
                
                // Download quality settings (placeholder for future implementation)
                SettingsEntry(
                    title = stringResource(R.string.download_quality),
                    text = stringResource(R.string.download_quality_description),
                    onClick = { /* Navigate to quality settings */ }
                )
            }
        }

        // Download behavior settings
        SettingsGroup(
            title = stringResource(R.string.download_behavior)
        ) {
            SwitchSettingsEntry(
                title = stringResource(R.string.wifi_only_downloads),
                text = stringResource(R.string.wifi_only_downloads_description),
                isChecked = DataPreferences.wifiOnlyDownloads,
                onCheckedChange = { DataPreferences.wifiOnlyDownloads = it }
            )
            
            SwitchSettingsEntry(
                title = stringResource(R.string.auto_download_at_half),
                text = stringResource(R.string.auto_download_at_half_description),
                isChecked = PlayerPreferences.autoDownloadAtHalf,
                onCheckedChange = { PlayerPreferences.autoDownloadAtHalf = it }
            )
        }
    }
}
