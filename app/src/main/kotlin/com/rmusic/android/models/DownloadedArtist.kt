package com.rmusic.android.models

import androidx.compose.runtime.Immutable
import androidx.room.Entity
import androidx.room.PrimaryKey

@Immutable
@Entity
data class DownloadedArtist(
    @PrimaryKey val id: String,
    val name: String,
    val thumbnailUrl: String? = null,
    val downloadedAt: Long = System.currentTimeMillis(),
    val bookmarkedAt: Long? = null,
    val songCount: Int = 0
) {
    fun toArtist() = Artist(
        id = id,
        name = name,
        thumbnailUrl = thumbnailUrl,
        timestamp = downloadedAt,
        bookmarkedAt = bookmarkedAt
    )
}
