package com.rmusic.download.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.rmusic.download.models.DownloadItem
import kotlinx.coroutines.flow.Flow

@Dao
interface DownloadDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun addDownload(item: DownloadItem)

    @Update
    suspend fun updateDownload(item: DownloadItem)

    @Query("DELETE FROM downloads WHERE id = :id")
    suspend fun removeDownload(id: String)

    @Query("SELECT * FROM downloads WHERE id = :id")
    suspend fun getDownload(id: String): DownloadItem?

    @Query("SELECT * FROM downloads ORDER BY createdAt DESC")
    fun getAllDownloads(): Flow<List<DownloadItem>>
}
