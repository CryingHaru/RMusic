package com.rmusic.providers.ytmusic.utils

import java.net.URLDecoder
import java.nio.charset.StandardCharsets

/**
 * Cookie management utility for YTMusic authentication
 * Handles parsing, validation, and management of authentication cookies
 */
class CookieManager {
    private var cookieCache: Map<String, String> = emptyMap()
    private var lastParsedCookieString: String? = null

    /**
     * Parse cookie string into key-value map
     * Supports both standard and YouTube-specific cookie formats
     */
    fun parseCookies(cookieString: String): Map<String, String> {
        if (cookieString == lastParsedCookieString && cookieCache.isNotEmpty()) {
            return cookieCache
        }

        val cookies = mutableMapOf<String, String>()
        
        try {
            cookieString.split(';').forEach { cookie ->
                val trimmedCookie = cookie.trim()
                if (trimmedCookie.isNotEmpty() && '=' in trimmedCookie) {
                    val parts = trimmedCookie.split('=', limit = 2)
                    if (parts.size == 2) {
                        val key = parts[0].trim()
                        val value = parts[1].trim()
                        
                        val decodedValue = try {
                            URLDecoder.decode(value, StandardCharsets.UTF_8.toString())
                        } catch (e: Exception) {
                            value
                        }
                        
                        cookies[key] = decodedValue
                    }
                }
            }
        } catch (e: Exception) {
            throw Exception("Failed to parse cookie string: ${e.message}")
        }

        cookieCache = cookies
        lastParsedCookieString = cookieString
        return cookies
    }

    
    fun validateAuthenticationCookies(cookies: Map<String, String>): Result<Boolean> = runCatching {
        // Requerimos solo una de estas: SAPISID o __Secure-3PAPISID
        val sapisid = cookies["SAPISID"] ?: cookies["__Secure-3PAPISID"]
        if (sapisid.isNullOrBlank()) throw Exception("Missing required cookie: SAPISID or __Secure-3PAPISID")
        if (!sapisid.matches(Regex("^[a-zA-Z0-9_-]+$"))) throw Exception("Invalid SAPISID format")
        true
    }

    fun extractVisitorData(cookies: Map<String, String>): String? {
        return cookies["VISITOR_INFO1_LIVE"]
    }

    
    fun extractSessionToken(cookies: Map<String, String>): String? {
        return cookies["SESSION_TOKEN"]
    }

    
    fun extractDataSyncId(cookies: Map<String, String>): String? {
        return cookies["DATASYNC_ID"]
    }

    
    fun getAuthCookies(cookies: Map<String, String>): Map<String, String> {
        // Minimal: conservar solo la cookie que identifica/autentica la cuenta
        val authCookieKeys = setOf("SAPISID", "__Secure-3PAPISID")
        return cookies.filterKeys { it in authCookieKeys }
    }

    
    fun formatCookiesString(cookies: Map<String, String>): String {
        return cookies.entries.joinToString("; ") { "${it.key}=${it.value}" }
    }

    
    fun hasLoginSession(cookies: Map<String, String>): Boolean {
        // Considerar sesión válida si tenemos la cookie de identificación
        return ("SAPISID" in cookies || "__Secure-3PAPISID" in cookies)
    }

    
    fun clearCookies() {
        cookieCache = emptyMap()
        lastParsedCookieString = null
    }

    
    fun mergeCookies(existingCookies: Map<String, String>, newCookies: Map<String, String>): Map<String, String> {
        return existingCookies + newCookies
    }

    
    fun areCookiesLikelyExpired(cookies: Map<String, String>): Boolean {
        
        val sessionCookies = cookies.filterKeys { 
            it.contains("SESSION", ignoreCase = true) || 
            it.contains("AUTH", ignoreCase = true) 
        }
        
        return sessionCookies.isEmpty()
    }
}
