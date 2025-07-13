package com.rmusic.download.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.rmusic.download.DownloadState

@Entity(tableName = "downloads")
data class DownloadEntity(
    @PrimaryKey val id: String,
    val trackId: String,
    val filePath: String,
    val state: DownloadState,
    val progress: Int
)
