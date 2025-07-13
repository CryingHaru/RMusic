package com.rmusic.download.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface DownloadDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(download: DownloadEntity)

    @Update
    suspend fun update(download: DownloadEntity)

    @Delete
    suspend fun delete(download: DownloadEntity)

    @Query("SELECT * FROM downloads WHERE id = :id")
    suspend fun getById(id: String): DownloadEntity?

    @Query("SELECT * FROM downloads")
    fun getAll(): Flow<List<DownloadEntity>>
}
