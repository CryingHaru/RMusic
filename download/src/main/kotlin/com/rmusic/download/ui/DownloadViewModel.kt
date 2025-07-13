package com.rmusic.download.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.launch
import com.rmusic.download.DownloadProvider
import com.rmusic.download.DownloadState
import com.rmusic.download.data.DownloadEntity
import com.rmusic.download.data.DownloadRepository

/**
 * ViewModel para gestionar descargas desde UI.
 * @param repository fuente de persistencia
 * @param provider implementación concreta de DownloadProvider
 */
class DownloadViewModel(
    private val repository: DownloadRepository,
    private val provider: DownloadProvider
) : ViewModel() {

    /** Flujo de descargas persistidas */
    val downloads: StateFlow<List<DownloadEntity>> =
        repository.getAllDownloads()
            .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    /** Inicia una descarga y persiste estado */
    fun startDownload(trackId: String) {
        viewModelScope.launch {
            provider.downloadTrack(trackId)
                .collect { state ->
                    // Actualizar o insertar entidad en base al estado
                    val entity = DownloadEntity(
                        id = trackId,
                        trackId = trackId,
                        filePath = "", // será completado en implementación concreta
                        state = state,
                        progress = when(state) {
                            DownloadState.RUNNING -> 0
                            DownloadState.COMPLETED -> 100
                            else -> 0
                        }
                    )
                    repository.upsert(entity)
                }
        }
    }

    /** Pausa descarga */
    fun pauseDownload(id: String) {
        viewModelScope.launch { provider.pauseDownload(id) }
    }

    /** Reanuda descarga */
    fun resumeDownload(id: String) {
        viewModelScope.launch { provider.resumeDownload(id) }
    }

    /** Cancela descarga */
    fun cancelDownload(id: String) {
        viewModelScope.launch { provider.cancelDownload(id) }
    }
}
