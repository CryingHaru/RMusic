package com.rmusic.providers.intermusic.utils

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.ConcurrentHashMap

class PoTokenManager {
    
    private val tokenCache = ConcurrentHashMap<String, CachedToken>()
    private val refreshMutex = Mutex()
    
    companion object {
        private const val TOKEN_VALIDITY_DURATION = 3600 * 1000L
        private const val REFRESH_THRESHOLD = 10 * 60 * 1000L
    }
    
    data class CachedToken(
        val token: String,
        val expiryTime: Long,
        val sessionId: String,
        val visitorData: String
    )

    suspend fun generatePoToken(sessionId: String, visitorData: String): String? {
        return try {
            val cacheKey = "${sessionId}_${visitorData}"
            val cachedToken = tokenCache[cacheKey]
            
            if (cachedToken != null && !isTokenExpired(cachedToken)) {
                return cachedToken.token
            }
            
            refreshMutex.withLock {
                val latestCached = tokenCache[cacheKey]
                if (latestCached != null && !isTokenExpired(latestCached)) {
                    return latestCached.token
                }
                
                val newToken = performTokenGeneration(sessionId, visitorData)
                if (newToken != null) {
                    val cachedTokenData = CachedToken(
                        token = newToken,
                        expiryTime = System.currentTimeMillis() + TOKEN_VALIDITY_DURATION,
                        sessionId = sessionId,
                        visitorData = visitorData
                    )
                    tokenCache[cacheKey] = cachedTokenData
                }
                newToken
            }
        } catch (e: Exception) {
            null
        }
    }

    suspend fun refreshPoToken(sessionId: String, visitorData: String): String? {
        val cacheKey = "${sessionId}_${visitorData}"
        val cachedToken = tokenCache[cacheKey]
        
        if (cachedToken == null || shouldRefreshToken(cachedToken)) {
            return generatePoToken(sessionId, visitorData)
        }
        
        return cachedToken.token
    }

    private fun shouldRefreshToken(token: CachedToken): Boolean {
        val currentTime = System.currentTimeMillis()
        return currentTime >= (token.expiryTime - REFRESH_THRESHOLD)
    }

    private fun isTokenExpired(token: CachedToken): Boolean {
        return System.currentTimeMillis() >= token.expiryTime
    }

    private suspend fun performTokenGeneration(sessionId: String, visitorData: String): String? {
        return try {
            val mockToken = generateMockPoToken(sessionId, visitorData)
            mockToken
        } catch (e: Exception) {
            null
        }
    }

 
    private fun generateMockPoToken(sessionId: String, visitorData: String): String {
        val timestamp = System.currentTimeMillis()
        val data = "$sessionId:$visitorData:$timestamp"
        val hash = data.hashCode().toString(16)
        return "mock_po_token_$hash"
    }

    
    fun getCachedToken(sessionId: String, visitorData: String): String? {
        val cacheKey = "${sessionId}_${visitorData}"
        val cachedToken = tokenCache[cacheKey]
        return if (cachedToken != null && !isTokenExpired(cachedToken)) {
            cachedToken.token
        } else {
            null
        }
    }

    fun removeToken(sessionId: String, visitorData: String) {
        val cacheKey = "${sessionId}_${visitorData}"
        tokenCache.remove(cacheKey)
    }

    fun clearTokens() {
        tokenCache.clear()
    }

    fun getExpiry(sessionId: String, visitorData: String): Long? {
        val cacheKey = "${sessionId}_${visitorData}"
        return tokenCache[cacheKey]?.expiryTime
    }

    fun hasValidToken(sessionId: String, visitorData: String): Boolean {
        val cacheKey = "${sessionId}_${visitorData}"
        val cachedToken = tokenCache[cacheKey]
        return cachedToken != null && !isTokenExpired(cachedToken)
    }

    fun purgeExpired() {
        val currentTime = System.currentTimeMillis()
        tokenCache.entries.removeIf { (_, token) -> currentTime >= token.expiryTime }
    }

    fun getCacheStats(): Map<String, Any> {
        val currentTime = System.currentTimeMillis()
        val validTokens = tokenCache.values.count { currentTime < it.expiryTime }
        val expiredTokens = tokenCache.size - validTokens
        return mapOf(
            "totalTokens" to tokenCache.size,
            "validTokens" to validTokens,
            "expiredTokens" to expiredTokens,
            "cacheKeys" to tokenCache.keys.toList()
        )
    }
}
