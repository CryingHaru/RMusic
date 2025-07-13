package com.rmusic.android.ui.screens.download

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.rmusic.download.data.DownloadRepository
import com.rmusic.download.InnertubeDownloadProvider
import com.rmusic.download.ui.DownloadViewModel

/**
 * Factory para crear DownloadViewModel con repositorio y provider.
 */
class DownloadViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(DownloadViewModel::class.java)) {
            val repo = DownloadRepository.getInstance(context)
            val provider = InnertubeDownloadProvider(context)
            @Suppress("UNCHECKED_CAST")
            return DownloadViewModel(repo, provider) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class: $modelClass")
    }
}
