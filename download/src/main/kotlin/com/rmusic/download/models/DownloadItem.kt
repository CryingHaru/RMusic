package com.rmusic.download.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.rmusic.download.DownloadState
import com.rmusic.download.DownloadStateConverter

@Entity(tableName = "downloads")
@TypeConverters(DownloadStateConverter::class)
data class DownloadItem(
    @PrimaryKey val id: String,
    val title: String,
    val artist: String?,
    val album: String?,
    val thumbnailUrl: String?,
    val duration: Long?,
    val url: String,
    val filePath: String,
    val state: DownloadState,
    val createdAt: Long = System.currentTimeMillis()
)
