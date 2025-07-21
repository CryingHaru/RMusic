package com.rmusic.android.models

import androidx.compose.runtime.Immutable
import androidx.room.Entity
import androidx.room.PrimaryKey

@Immutable
@Entity
data class DownloadedAlbum(
    @PrimaryKey val id: String,
    val title: String,
    val description: String? = null,
    val thumbnailUrl: String? = null,
    val year: String? = null,
    val authorsText: String? = null,
    val shareUrl: String? = null,
    val downloadedAt: Long = System.currentTimeMillis(),
    val bookmarkedAt: Long? = null,
    val otherInfo: String? = null,
    val songCount: Int = 0
) {
    fun toAlbum() = Album(
        id = id,
        title = title,
        description = description,
        thumbnailUrl = thumbnailUrl,
        year = year,
        authorsText = authorsText,
        shareUrl = shareUrl,
        timestamp = downloadedAt,
        bookmarkedAt = bookmarkedAt,
        otherInfo = otherInfo
    )
}
