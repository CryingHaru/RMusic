package com.rmusic.download

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import com.rmusic.download.data.DownloadRepository
import com.rmusic.download.data.DownloadEntity
import com.rmusic.download.DownloadState
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.utils.io.ByteReadChannel
import kotlinx.coroutines.flow.first
import java.io.File
import java.io.FileOutputStream

/**
 * Worker para realizar descargas en background con WorkManager.
 * InputData debe contener:
 * - "TRACK_ID": String
 * - "DOWNLOAD_URL": String
 */
class DownloadWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val trackId = inputData.getString(KEY_TRACK_ID) ?: return Result.failure()
        val downloadUrl = inputData.getString(KEY_DOWNLOAD_URL) ?: return Result.failure()
        val context = applicationContext

        // Preparar repositorio y DAO
        val repository = DownloadRepository.getInstance(context)

        // Registrar inicio
        repository.upsert(DownloadEntity(
            id = trackId,
            trackId = trackId,
            filePath = "",
            state = DownloadState.RUNNING,
            progress = 0
        ))

        return try {
            // Archivo de destino
            val downloadsDir = context.getExternalFilesDir("downloads") ?: context.filesDir
            if (!downloadsDir.exists()) downloadsDir.mkdirs()
            val file = File(downloadsDir, "${trackId}.mp3")
            val output = FileOutputStream(file).buffered()

            // Descargar stream
            val httpClient = HttpClient() // TODO: usar cliente global
            val channel: ByteReadChannel = httpClient.get(downloadUrl).body()
            val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
            while (!channel.isClosedForRead) {
                val count = channel.readAvailable(buffer)
                if (count <= 0) break
                output.write(buffer, 0, count)
            }
            output.flush()
            output.close()

            // Registrar completado
            repository.upsert(DownloadEntity(
                id = trackId,
                trackId = trackId,
                filePath = file.absolutePath,
                state = DownloadState.COMPLETED,
                progress = 100
            ))
            Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            repository.upsert(DownloadEntity(
                id = trackId,
                trackId = trackId,
                filePath = "",
                state = DownloadState.FAILED,
                progress = 0
            ))
            Result.failure()
        }
    }

    companion object {
        const val KEY_TRACK_ID = "TRACK_ID"
        const val KEY_DOWNLOAD_URL = "DOWNLOAD_URL"
        private const val DEFAULT_BUFFER_SIZE = 8 * 1024
    }
}
