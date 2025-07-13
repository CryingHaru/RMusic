package com.rmusic.download

/**
 * States for download lifecycle.
 */
enum class DownloadState {
    PENDING,
    RUNNING,
    PAUSED,
    COMPLETED,
    FAILED
}
