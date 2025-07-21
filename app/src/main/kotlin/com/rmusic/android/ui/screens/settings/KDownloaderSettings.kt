package com.rmusic.android.ui.screens.settings

import com.rmusic.android.ui.screens.Route
import com.rmusic.compose.routing.Route0
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.rmusic.android.R
import com.rmusic.android.service.MusicDownloadService
import com.rmusic.android.ui.components.themed.SecondaryTextButton
import com.rmusic.core.ui.LocalAppearance
import com.rmusic.android.ui.screens.settings.SettingsCategoryScreen
import com.rmusic.android.ui.screens.settings.SettingsGroup
import com.rmusic.android.ui.screens.settings.SettingsEntry
import com.rmusic.android.ui.screens.settings.SettingsDescription
import androidx.compose.material3.MaterialTheme
import androidx.compose.foundation.clickable
import com.rmusic.android.utils.semiBold

@Route
@Composable
fun KDownloaderSettings() {
    val context = LocalContext.current
    val (colorPalette, typography) = LocalAppearance.current
    
    var showCleanupDialog by remember { mutableStateOf(false) }
    var showCancelAllDialog by remember { mutableStateOf(false) }
    
    // Get download state from service
    val isDownloading by com.rmusic.android.service.downloadState.collectAsState()
    val activeDownloads by com.rmusic.android.service.activeDownloads.collectAsState()

    SettingsCategoryScreen(title = stringResource(R.string.kdownloader_settings)) {
        SettingsGroup(
            title = stringResource(R.string.download_management)
        ) {
            // Download status
            SettingsEntry(
                title = stringResource(R.string.active_downloads),
                text = stringResource(R.string.active_downloads_count, activeDownloads.size),
                onClick = { /* Could navigate to downloads screen */ }
            )
            
            // Pause/Resume all downloads
            if (activeDownloads.isNotEmpty()) {
                SettingsEntry(
                    title = if (isDownloading) {
                        stringResource(R.string.pause_all_downloads)
                    } else {
                        stringResource(R.string.resume_all_downloads)
                    },
                    text = stringResource(R.string.pause_resume_all_description),
                    onClick = {
                        // Implementation for pause/resume all
                        activeDownloads.forEach { download ->
                            if (isDownloading) {
                                MusicDownloadService.pause(context, download.id)
                            } else {
                                MusicDownloadService.resume(context, download.id)
                            }
                        }
                    }
                )
            }
            
            // Cancel all downloads
            if (activeDownloads.isNotEmpty()) {
                SettingsEntry(
                    title = stringResource(R.string.cancel_all_downloads),
                    text = stringResource(R.string.cancel_all_downloads_description),
                    onClick = { showCancelAllDialog = true }
                )
            }
        }

        SettingsGroup(
            title = stringResource(R.string.cleanup_and_maintenance)
        ) {
            // Clean up old resumed files
            SettingsEntry(
                title = stringResource(R.string.cleanup_old_files),
                text = stringResource(R.string.cleanup_old_files_description),
                onClick = { showCleanupDialog = true }
            )
        }

        SettingsGroup(
            title = stringResource(R.string.kdownloader_info)
        ) {
            SettingsDescription(
                text = stringResource(R.string.kdownloader_description)
            )
            
            // KDownloader features
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = stringResource(R.string.kdownloader_features),
                    style = typography.s.semiBold,
                    color = colorPalette.text,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
                
                val features = listOf(
                    stringResource(R.string.feature_pause_resume),
                    stringResource(R.string.feature_large_files),
                    stringResource(R.string.feature_parallel_downloads),
                    stringResource(R.string.feature_progress_tracking),
                    stringResource(R.string.feature_error_handling)
                )
                
                features.forEach { feature ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            painter = painterResource(R.drawable.heart),
                            contentDescription = null,
                            tint = colorPalette.accent,
                            modifier = Modifier.padding(end = 8.dp)
                        )
                        Text(
                            text = feature,
                            style = typography.xs,
                            color = colorPalette.textSecondary
                        )
                    }
                }
            }
        }
    }

    // Cleanup Dialog
    if (showCleanupDialog) {
        com.rmusic.android.ui.components.themed.ConfirmationDialog(
            text = stringResource(R.string.cleanup_confirmation),
            onDismiss = { showCleanupDialog = false },
            onConfirm = {
                // Cleanup old files (7 days old)
                MusicDownloadService.cleanUp(context, 7)
                showCleanupDialog = false
            }
        )
    }

    // Cancel All Dialog
    if (showCancelAllDialog) {
        com.rmusic.android.ui.components.themed.ConfirmationDialog(
            text = stringResource(R.string.cancel_all_confirmation),
            onDismiss = { showCancelAllDialog = false },
            onConfirm = {
                // Cancel all downloads
                activeDownloads.forEach { download ->
                    MusicDownloadService.cancel(context, download.id)
                }
                showCancelAllDialog = false
            },
            confirmText = stringResource(R.string.cancel_all)
        )
    }
}
