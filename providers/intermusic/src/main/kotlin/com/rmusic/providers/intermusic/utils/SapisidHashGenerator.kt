package com.rmusic.providers.intermusic.utils

import java.security.MessageDigest
import java.nio.charset.StandardCharsets

/**
 * SAPISID Hash Generator for YouTube Music authentication
 */
class SapisidHashGenerator {
    companion object {
        private const val YOUTUBE_MUSIC_ORIGIN = "https://music.youtube.com"
    }

    fun generate(sapisid: String, timestamp: Long = System.currentTimeMillis() / 1000): String {
        val hashInput = "$timestamp $sapisid $YOUTUBE_MUSIC_ORIGIN"
        val hash = sha1(hashInput)
        return "${timestamp}_$hash"
    }

    fun generateWithOrigin(sapisid: String, origin: String, timestamp: Long = System.currentTimeMillis() / 1000): String {
        val hashInput = "$timestamp $sapisid $origin"
        val hash = sha1(hashInput)
        return "${timestamp}_$hash"
    }

    fun extractTimestamp(hash: String): Long? = runCatching { hash.substringBefore('_').toLong() }.getOrNull()

    fun isHashExpired(hash: String, maxAgeSeconds: Long = 3600): Boolean {
        val ts = extractTimestamp(hash) ?: return true
        val now = System.currentTimeMillis() / 1000
        return (now - ts) > maxAgeSeconds
    }

    private fun sha1(input: String): String {
        val digest = MessageDigest.getInstance("SHA-1")
        val bytes = input.toByteArray(StandardCharsets.UTF_8)
        val hashBytes = digest.digest(bytes)
        return hashBytes.joinToString("") { "%02x".format(it) }
    }
}
