package com.rmusic.android.models

import androidx.compose.runtime.Immutable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Immutable
@Entity
data class DownloadedSong(
    @PrimaryKey val id: String,
    val title: String,
    val artistsText: String? = null,
    val albumTitle: String? = null,
    val durationText: String?,
    val thumbnailUrl: String?,
    val filePath: String,
    val fileSize: Long,
    val downloadedAt: Long = System.currentTimeMillis(),
    val likedAt: Long? = null,
    val totalPlayTimeMs: Long = 0,
    val loudnessBoost: Float? = null,
    @ColumnInfo(defaultValue = "false")
    val blacklisted: Boolean = false,
    @ColumnInfo(defaultValue = "false")
    val explicit: Boolean = false
) {
    fun toggleLike() = copy(likedAt = if (likedAt == null) System.currentTimeMillis() else null)
    
    fun toSong() = Song(
        id = id,
        title = title,
        artistsText = artistsText,
        durationText = durationText,
        thumbnailUrl = thumbnailUrl,
        likedAt = likedAt,
        totalPlayTimeMs = totalPlayTimeMs,
        loudnessBoost = loudnessBoost,
        blacklisted = blacklisted,
        explicit = explicit
    )
}
