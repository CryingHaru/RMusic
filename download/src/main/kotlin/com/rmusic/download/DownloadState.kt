package com.rmusic.download

import androidx.room.TypeConverter

sealed class DownloadState {
    data object Queued : DownloadState()
    data class Downloading(val progress: Float, val downloadedBytes: Long, val totalBytes: Long) : DownloadState()
    data object Paused : DownloadState()
    data class Completed(val filePath: String) : DownloadState()
    data object Cancelled : DownloadState()
    data class Failed(val error: Throwable, val isRetryable: Boolean = false) : DownloadState()
}

class DownloadStateConverter {
    @TypeConverter
    fun fromState(state: DownloadState): String {
        return when (state) {
            is DownloadState.Queued -> "QUEUED"
            is DownloadState.Downloading -> "DOWNLOADING:${state.progress}:${state.downloadedBytes}:${state.totalBytes}"
            is DownloadState.Paused -> "PAUSED"
            is DownloadState.Completed -> "COMPLETED:${state.filePath}"
            is DownloadState.Cancelled -> "CANCELLED"
            is DownloadState.Failed -> "FAILED:${state.error.message ?: state.error.toString()}::${state.isRetryable}"
        }
    }

    @TypeConverter
    fun toState(stateString: String): DownloadState {
        return when {
            stateString == "QUEUED" -> DownloadState.Queued
            stateString.startsWith("DOWNLOADING:") -> {
                val parts = stateString.substringAfter("DOWNLOADING:").split(":")
                val progress = parts.getOrNull(0)?.toFloatOrNull() ?: 0f
                val downloadedBytes = parts.getOrNull(1)?.toLongOrNull() ?: 0L
                val totalBytes = parts.getOrNull(2)?.toLongOrNull() ?: 0L
                DownloadState.Downloading(progress, downloadedBytes, totalBytes)
            }
            stateString == "PAUSED" -> DownloadState.Paused
            stateString.startsWith("COMPLETED:") -> {
                val filePath = stateString.substringAfter("COMPLETED:")
                DownloadState.Completed(filePath)
            }
            stateString == "CANCELLED" -> DownloadState.Cancelled
            stateString.startsWith("FAILED:") -> {
                val content = stateString.substringAfter("FAILED:")
                val parts = content.split("::")
                val errorMessage = parts.getOrNull(0) ?: "Unknown error"
                val isRetryable = parts.getOrNull(1)?.toBoolean() ?: false
                DownloadState.Failed(Exception(errorMessage), isRetryable)
            }
            else -> DownloadState.Failed(Exception("Unknown state: $stateString"), false)
        }
    }
}
