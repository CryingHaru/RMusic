package com.rmusic.download.data

import android.content.Context
import kotlinx.coroutines.flow.Flow

/**
 * Repositorio para gestionar las descargas y su persistencia.
 */
class DownloadRepository private constructor(
    private val dao: DownloadDao
) {
    /** Lista de todas las descargas como flujo. */
    fun getAllDownloads(): Flow<List<DownloadEntity>> = dao.getAll()

    /** Inserta o actualiza una descarga. */
    suspend fun upsert(download: DownloadEntity) {
        dao.insert(download)
    }

    /** Elimina una descarga. */
    suspend fun delete(download: DownloadEntity) {
        dao.delete(download)
    }

    companion object {
        @Volatile
        private var INSTANCE: DownloadRepository? = null

        fun getInstance(context: Context): DownloadRepository =
            INSTANCE ?: synchronized(this) {
                val db = DownloadDatabase.getInstance(context)
                DownloadRepository(db.downloadDao()).also { INSTANCE = it }
            }
    }
}
