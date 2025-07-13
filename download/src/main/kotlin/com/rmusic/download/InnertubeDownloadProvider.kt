package com.rmusic.download

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

/**
 * Implementación de DownloadProvider basado en WorkManager para Innertube.
 */
class InnertubeDownloadProvider(
    private val context: Context
) : DownloadProvider {

    override fun downloadTrack(trackId: String): Flow<DownloadState> = flow {
        emit(DownloadState.PENDING)
        // Obtener URL real desde Innertube provider (TODO)
        val downloadUrl = "https://example.com/track/$trackId/download"
        // Encolar worker único
        val workManager = WorkManager.getInstance(context)
        val req = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setInputData(workDataOf(
                DownloadWorker.KEY_TRACK_ID to trackId,
                DownloadWorker.KEY_DOWNLOAD_URL to downloadUrl
            ))
            .build()
        workManager.enqueueUniqueWork(trackId, ExistingWorkPolicy.REPLACE, req)
        emit(DownloadState.RUNNING)
        // La UI debe observar el repositorio para COMPLETED/FAILED
    }

    override suspend fun pauseDownload(id: String) {
        // Cancelar el work actual (no hay pausa real con WorkManager)
        WorkManager.getInstance(context).cancelUniqueWork(id)
    }

    override suspend fun resumeDownload(id: String) {
        // Re-encolar descarga
        downloadTrack(id)
            .collect { /* no hace nada, solo encola */ }
    }

    override suspend fun cancelDownload(id: String) {
        // Mismo que pausa: cancelar job y limpiar datos si necesario
        WorkManager.getInstance(context).cancelUniqueWork(id)
    }
}
