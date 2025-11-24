package com.rmusic.providers.utils

import kotlinx.coroutines.CancellationException

inline fun <T> runCatchingCancellable(block: () -> T): Result<T> =
    runCatching(block).onFailure { throwable ->
        if (throwable is CancellationException) throw throwable
    }
