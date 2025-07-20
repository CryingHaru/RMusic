package com.rmusic.android.utils

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import com.rmusic.android.Database

@Composable
fun isDownloaded(mediaId: String): Boolean {
    val downloadedSongs by Database.downloadedSongs().collectAsState(initial = emptyList())
    return remember(downloadedSongs, mediaId) {
        downloadedSongs.any { it.id == "download:$mediaId" }
    }
}
