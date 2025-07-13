package com.rmusic.download.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [DownloadEntity::class], version = 1)
abstract class DownloadDatabase : RoomDatabase() {
    abstract fun downloadDao(): DownloadDao

    companion object {
        @Volatile private var INSTANCE: DownloadDatabase? = null

        fun getInstance(context: Context): DownloadDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    DownloadDatabase::class.java,
                    "download_db"
                ).build().also { INSTANCE = it }
            }
    }
}
