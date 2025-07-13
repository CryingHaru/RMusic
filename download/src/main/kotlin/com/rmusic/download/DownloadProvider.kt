package com.rmusic.download

import kotlinx.coroutines.flow.Flow

/**
 * Interfaz común para los proveedores de descarga.
 */
interface DownloadProvider {
    /**
     * Inicia la descarga de una pista y emite el estado de progreso.
     * @param trackId identificador único de la pista.
     */
    fun downloadTrack(trackId: String): Flow<DownloadState>

    /** Pausa la descarga en curso. */
    suspend fun pauseDownload(id: String)

    /** Reanuda una descarga pausada. */
    suspend fun resumeDownload(id: String)

    /** Cancela la descarga. */
    suspend fun cancelDownload(id: String)
}
