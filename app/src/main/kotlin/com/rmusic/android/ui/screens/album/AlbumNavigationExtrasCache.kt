package com.rmusic.android.ui.screens.album

import java.util.concurrent.ConcurrentHashMap

object AlbumNavigationExtrasCache {
    private val paramsCache = ConcurrentHashMap<String, String?>()

    fun put(browseId: String, params: String?) {
        if (params.isNullOrBlank()) {
            paramsCache.remove(browseId)
        } else {
            paramsCache[browseId] = params
        }
    }

    fun consume(browseId: String): String? = paramsCache.remove(browseId)
}
